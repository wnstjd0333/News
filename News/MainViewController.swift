//
//  ViewController.swift
//  News
//
//  Created by kimjunseong on 2020/02/12.
//  Copyright © 2020 kimjunseong. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SDWebImage

class MainViewController: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet weak var toSelectCountryButton: UIButton!
    @IBOutlet weak var countryText: UILabel!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var newsSegmentControl: UISegmentedControl!
    @IBOutlet weak var MainPageControl: UIPageControl!
    @IBOutlet weak var topHeadingTableView: UITableView!
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var everythingTableView: UITableView!
    @IBOutlet weak var sourceTableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var titleBar: UINavigationItem!
    
    var internationalData = [Article]()
    var keywardData = [Article]()
    var providerData = [Source]()
    var service : NewsService?
    var fetchingMore = false
    var countryCode = "us" //CountryCollectionViewController의 countries 속성 중 선택
    var searchedText = "trump" //KeywardData의 초기 검색값
    var storedText = "" //keayward 저장값
    let pageSize = 20
    var internationalPage = 0
    var keywardPage = 1 // default가 0보다 커야한다. (Int)
    var resetIndex = 0 // 0이면 refresh가능, 1이면 불가능 (기사 100개가 최대이다)
    
    //MARK: action
    @IBAction func newsSwitchControlTapped(_ sender: UISegmentedControl) {
        
        let x = Int(mainScrollView.frame.size.width * CGFloat(sender.selectedSegmentIndex))
        mainScrollView.setContentOffset(CGPoint(x: x, y:0), animated: false)
        
        if newsSegmentControl.selectedSegmentIndex == 0 {
            
            if internationalData.count == 0 && resetIndex == 0{
                topHeadingTableView.alpha = 0
                return
                
            } else {
                topHeadingTableView.alpha = 1
                topHeadingTableView.scrollToRow(at: IndexPath(row: 0, section: 0),
                                                at: .top, animated: false)
            }
            toSelectCountryButton.alpha = 1
            searchBar.alpha = 0
            let text = String(format: NSLocalizedString("main_country_select_text", comment: ""), countryCode.uppercased())
            countryText.text = text
            searchBar.resignFirstResponder()
            
        } else if newsSegmentControl.selectedSegmentIndex == 1 {
            
            if keywardData.count == 0 && resetIndex == 0 {
                everythingTableView.alpha = 0
                return
                
            } else {
                everythingTableView.alpha = 1
                everythingTableView.scrollToRow(at: IndexPath(row: 0, section: 0),
                                                at: .top, animated: false)
            }
            toSelectCountryButton.alpha = 0
            searchBar.alpha = 1
            countryText.text = ""

        } else {
            sourceTableView.scrollToRow(at: IndexPath(row: 0, section: 0),
                                        at: .top, animated: false)
            toSelectCountryButton.alpha = 0
            searchBar.alpha = 0
            countryText.text = "List of News source"
            searchBar.resignFirstResponder()
        }
    }
    
    @IBAction func countryButtonClicked(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(identifier: "Country") as? CountryCollectionViewController else {
            return
        }
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }

    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleBar.title = NSLocalizedString("app_title", comment: "")
        let text = String(format: NSLocalizedString("main_country_select_text", comment: ""), countryCode.uppercased())
        countryText.text = text
        
        toSelectCountryButton.layer.cornerRadius = 10

        searchBar.delegate = self
        topHeadingTableView.delegate = self
        topHeadingTableView.dataSource = self
        everythingTableView.delegate = self
        everythingTableView.dataSource = self
        sourceTableView.delegate = self
        sourceTableView.dataSource = self
        mainScrollView.delegate = self
        mainScrollView.isPagingEnabled = true
        
        applyInternational(countryCode)
        applyKeyword(searchedText)
        applyNewsProvider()
        
        doRefresh(topHeadingTableView)
        doRefresh(everythingTableView)
        doRefresh(sourceTableView)
    }
    
    //refresh Control
    @objc func refresh(sender: UIRefreshControl){
        if newsSegmentControl.selectedSegmentIndex == 0 {
            if resetIndex == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                    self.applyInternational(self.countryCode)
                    self.topHeadingTableView.reloadData()
                    sender.endRefreshing()
                })
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                    self.internationalPage = 0
                    self.applyInternational(self.countryCode)
                    self.topHeadingTableView.reloadData()
                    sender.endRefreshing()
                })
            }
        }
        
        if newsSegmentControl.selectedSegmentIndex == 1 {
            if resetIndex == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                    self.applyKeyword("\(self.searchedText)")
                    self.everythingTableView.reloadData()
                    sender.endRefreshing()
                })
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                    self.keywardPage = 1
                    self.applyKeyword("\(self.storedText)")
                    self.everythingTableView.reloadData()
                    sender.endRefreshing()
                })
            }
        }
        if newsSegmentControl.selectedSegmentIndex == 2 {
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                 self.applyNewsProvider()
                 self.sourceTableView.reloadData()
                 sender.endRefreshing()
             })
        }
    }

    func doRefresh(_ tableView: UITableView){
        let refreshControl = UIRefreshControl()
            tableView.refreshControl = refreshControl
            refreshControl.addTarget(self, action: #selector(MainViewController.refresh(sender:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func applyInternational(_ savedCountryCode: String){
        //이미지가 다운되는동안 request
        startAnimating(CGSize(width: 30.0, height: 30.0), message: "Loadding",
                       type: NVActivityIndicatorType.ballPulse, fadeInAnimation: nil)
       
        service = NewsService()
        self.topHeadingTableView.alpha = 1
        self.resetIndex = 0
        service?.fetchInternationalNews(countryCode: savedCountryCode, page: internationalPage, pageSize: pageSize) { (success, articles) in
           
            if !success { print("fail")
                DispatchQueue.main.async {
                //데이터를 받으면 response, MainThread에서 실행
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
                }
                return
    
            }
            guard let items = articles else { print("no data!"); return }
            self.internationalData = items
            
             DispatchQueue.main.async {
                if articles?.count == 0 {
                    self.topHeadingTableView.alpha = 0
                }
                
                self.internationalPage = self.internationalData.count / (self.pageSize - 1)
                
                //이미지를 받으면 response, MainThread에서 실행
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
                self.topHeadingTableView.reloadData()
             }
         }
    }
    
    func applyKeyword(_ searchedText : String){
       //데이터가 다운되는동안 request
        startAnimating(CGSize(width: 30.0, height: 30.0), message: "Loadding",
                       type: NVActivityIndicatorType.ballPulse, fadeInAnimation: nil)
        
        service = NewsService()
        self.everythingTableView.alpha = 1
        self.resetIndex = 0
        service?.fetchKeywordNews(keyword: searchedText, page: keywardPage, pageSize: pageSize) { (success, articles) in
            
            if !success { print("fail")
                DispatchQueue.main.async {
                //데이터를 받으면 response, MainThread에서 실행
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
                }
                return
            }
            guard let items = articles else { print("no data!"); return}
            self.keywardData = items

            DispatchQueue.main.async {
                if articles?.count == 0 {
                    self.everythingTableView.alpha = 0
                }
                
                self.keywardPage = self.keywardData.count / (self.pageSize - 1)

                //데이터를 받으면 response, MainThread에서 실행
                 NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
                self.everythingTableView.reloadData()
            }
        }
    }
    
    func applyNewsProvider(){
        service = NewsService()
        service?.fetchNewsProviders { (success, sources) in
            if !success { print("fail"); return }
            guard let items = sources else { print("no data!"); return }
            self.providerData = items
                
            DispatchQueue.main.async {
                self.sourceTableView.reloadData()
            }
        }
    }
    //identify로 테이블을 찾기 위한 메소드
    func checkTableView(_ tableView: UITableView) -> String {
        if tableView == topHeadingTableView {
            return "TopHeadingTableViewCell"
        }else if tableView == everythingTableView {
            return "EverythingTableViewCell"
        }else if tableView == sourceTableView{
            return "SourceTableViewCell"
        }
        return ""
    }
    
    func maximumAlert(){
        let alertController = UIAlertController(title: "Result", message: "100 articles are maximum", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}

//MARK: UITableViewDataSource
extension MainViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellIndentifier = checkTableView(tableView)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIndentifier,
                                                 for: indexPath) as! NewsTableViewCell
        
        if cellIndentifier == "TopHeadingTableViewCell" {
            
            let dataAtRow = internationalData[indexPath.row]
            cell.titleLabel.text           = dataAtRow.title
            cell.publishedAtLabel.text     = dataAtRow.publishedAt
            cell.sourceLabel.text          = dataAtRow.author ?? "익명"
            cell.newsDescriptionLabel.text = dataAtRow.description
            
            //TODO: URL주소가 있음에도 로드가 안되는 이미지가 있다.
            let remoteImageURL = URL(string: dataAtRow.urlToImage ?? "https://upload.wikimedia.org/wikipedia/ja/b/b5/Noimage_image.png")

            cell.urlToImage?.sd_setImage(with: remoteImageURL)
            
        } else if cellIndentifier == "EverythingTableViewCell"  {

            let dataAtRow = keywardData[indexPath.row]
            cell.titleLabel.text           = dataAtRow.title
            cell.publishedAtLabel.text     = dataAtRow.publishedAt
            cell.sourceLabel.text          = dataAtRow.author ?? "익명"
            cell.newsDescriptionLabel.text = dataAtRow.description

            let remoteImageURL = URL(string: dataAtRow.urlToImage ?? "https://upload.wikimedia.org/wikipedia/ja/b/b5/Noimage_image.png")

            cell.urlToImage?.sd_setImage(with: remoteImageURL)

        } else {
            let dataAtRow = providerData[indexPath.row]
            cell.nameLabel.text         = dataAtRow.name
            cell.sourceDescription.text = dataAtRow.description
            cell.languageLabel.text     = "Language: " + (dataAtRow.language ?? "")
            cell.countryLabel.text      = "Country: " + (dataAtRow.country ?? "")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == topHeadingTableView {
            return internationalData.count
            
        } else if tableView == everythingTableView {
            return keywardData.count
        
        } else {
            return providerData.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.sourceTableView {
             return
         }

        let alert = UIAlertController(title: "Original URL", message: "Are you sure going the page?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)

            if tableView == self.topHeadingTableView {
                let urlString = self.internationalData[indexPath.row].url ?? ""
                if let url = URL(string: urlString){
                    UIApplication.shared.open(url, options: [:])
                }

                print(self.internationalData[indexPath.row].urlToImage ?? "nil")
             }

            if tableView == self.everythingTableView {
                let urlString = self.keywardData[indexPath.row].url ?? ""
                if let url = URL(string: urlString){
                    UIApplication.shared.open(url, options: [:])
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "NO", style: .default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)

        }))
            self.present(alert, animated: true, completion: nil)
    }
}

//MARK: UITableViewDelegate
extension MainViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

//MARK: UIScrollViewDelegate
extension MainViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = mainScrollView.frame.size.width
        let fractionalPage = mainScrollView.contentOffset.x / pageWidth
        MainPageControl.currentPage = Int(fractionalPage)

        if MainPageControl.currentPage == 0 {
            newsSegmentControl.selectedSegmentIndex = 0
            toSelectCountryButton.alpha = 1
            searchBar.alpha = 0
            let text = String(format: NSLocalizedString("main_country_select_text", comment: ""), countryCode.uppercased())
            countryText.text = text
            searchBar.resignFirstResponder()

        } else if MainPageControl.currentPage == 1 {
            newsSegmentControl.selectedSegmentIndex = 1
            toSelectCountryButton.alpha = 0
            searchBar.alpha = 1
            countryText.text = ""

        } else {
            newsSegmentControl.selectedSegmentIndex = 2
            toSelectCountryButton.alpha = 0
            searchBar.alpha = 0
            countryText.text = "List of News source"
            searchBar.resignFirstResponder()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            if newsSegmentControl.selectedSegmentIndex == 0 {
            
                startAnimating(CGSize(width: 30.0, height: 30.0), message: "Loadding",
                               type: NVActivityIndicatorType.ballPulse, fadeInAnimation: nil)
            
                service?.fetchInternationalNews(countryCode: countryCode, page: internationalPage, pageSize: pageSize) { (success, articles) in
                  
                   if !success { print("fail"); return }
                   guard let items = articles else { print("no data!"); return }
                   self.internationalData.append(contentsOf: items)
                   
                        DispatchQueue.main.async {
                            if articles?.count == 0 {
                                self.resetIndex = 1
                                self.maximumAlert()
                            }
                    
                        self.internationalPage = self.internationalData.count / (self.pageSize - 1)
                        print("page:\(self.internationalPage)")
                        //이미지를 받으면 response, MainThread에서 실행
                        NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
                        self.topHeadingTableView.reloadData()
                    }
                    
                }
            }
            if newsSegmentControl.selectedSegmentIndex == 1 {
                
                startAnimating(CGSize(width: 30.0, height: 30.0), message: "Loadding",
                               type: NVActivityIndicatorType.ballPulse, fadeInAnimation: nil)
                
                if storedText == "" {
                    storedText = searchedText
                }
                
                service?.fetchKeywordNews(keyword: storedText, page: keywardPage, pageSize: pageSize) { (success, articles) in

                   if !success { print("fail"); return }
                   guard let items = articles else { print("no data!"); return }
                    self.keywardData.append(contentsOf: items)

                        DispatchQueue.main.async {
                            if self.keywardPage == 5 {
                                self.resetIndex = 1
                                self.maximumAlert()
                                NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
                                return
                            }

                        self.keywardPage = self.keywardData.count / (self.pageSize - 1)
                        print("page:\(self.keywardPage)")
                        //이미지를 받으면 response, MainThread에서 실행
                        NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
                        self.everythingTableView.reloadData()
                    }
                }
            }
        }
    }
}

//MARK: NewsDetailViewControllerDelegate
extension MainViewController : NewsDetailViewControllerDelegate {
     func getNewsItems() -> [Article]? {
        if newsSegmentControl.selectedSegmentIndex == 0 {
            return internationalData
        } else if newsSegmentControl.selectedSegmentIndex == 1 {
            return keywardData
        }
        return internationalData
    }
}

//MARK: CountryCollectionControllerDelegate
extension MainViewController : CountryCollectionControllerDelegate {
    func countryApplyToService(_ savedCountryCode: String) {
        countryCode = savedCountryCode
        internationalPage = 0
        applyInternational(countryCode)
        let text = String(format: NSLocalizedString("main_country_select_text", comment: ""), countryCode.uppercased())
        countryText.text = text
    }
}

//MARK: UISearchBarDelegate
extension MainViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchBarText = searchBar.text else { return }
        keywardPage = 1
        applyKeyword(searchBarText)
        storedText = searchBarText
        searchBar.resignFirstResponder()
    }
}
