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
    
    var internationalData = [Article]()
    var keywardData = [Article]()
    var providerData = [Source]()
    var service : NewsService?
    var article = Article()
    
    var fetchingMore = false // 기사의 가장 아래로 스크롤울 내리면 true로 바뀜
    var offset: Int = 1 // 2로 바뀌면 기사를 더 가져온다. applyInternational() 참조
    let ViewFrame = UIScreen.main.bounds
    
    var countryCode = "us" //CountryCollectionViewController의 countries 속성 중 선택
    var searchedText = "trump" //KeywardData의 초기 검색값
    
    //MARK: action
    @IBAction func newsSwitchControlTapped(_ sender: UISegmentedControl) {
        
        let x = Int(mainScrollView.frame.size.width * CGFloat(sender.selectedSegmentIndex))
        mainScrollView.setContentOffset(CGPoint(x: x, y:0), animated: false)
        
        if newsSegmentControl.selectedSegmentIndex == 0 {
            
            if internationalData.count == 0 {
                keywardAlert()
                return
            } else {
                topHeadingTableView.scrollToRow(at: IndexPath(row: 0, section: 0),
                                                at: .top, animated: false)
            }
            toSelectCountryButton.alpha = 1
            searchBar.alpha = 0
            countryText.text = "What's News today in \(countryCode.uppercased())"
            searchBar.resignFirstResponder()
            
        } else if newsSegmentControl.selectedSegmentIndex == 1 {
            
            if keywardData.count == 0 {
                keywardAlert()
                return
            } else {
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
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(MainViewController.refreshControlValueChanged(sender:)), for: .valueChanged)
        self.topHeadingTableView.addSubview(refreshControl)
        
        self.createLoadingCell()
        applyInternational(countryCode, 1)
        doRefresh(topHeadingTableView)
        doRefresh(everythingTableView)
        doRefresh(sourceTableView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        applyKeyword(searchedText)
        applyNewsProvider()
    }
    
    //MARK: refresh Control
    @objc func refresh(sender: UIRefreshControl){
        if newsSegmentControl.selectedSegmentIndex == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                self.applyInternational(self.countryCode, 1)
                self.topHeadingTableView.reloadData()
                sender.endRefreshing()
            })
        }
        
        if newsSegmentControl.selectedSegmentIndex == 1 {
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                self.applyKeyword("stock")
                self.everythingTableView.reloadData()
                sender.endRefreshing()
            })
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
    
    //TODO: Infinite Scrolling 다음 셀을 나타나게 할 것
    @objc func refreshControlValueChanged(sender: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.internationalData.removeAll()
            self.createLoadingCell()
            self.fetchingMore = true
            self.applyInternational(self.countryCode, 1)
            self.topHeadingTableView.reloadData()
            sender.endRefreshing()
        })
    }

    func createLoadingCell()  {
        self.topHeadingTableView.register(cellType: LoadingTableViewCell.self)
        let footerCell: UITableViewCell = self.topHeadingTableView.dequeueReusableCell(withIdentifier: "LoadingTableViewCell")!
            (footerCell as! LoadingTableViewCell).startAnimating()
            let footerView: UIView = footerCell.contentView
            self.topHeadingTableView.tableFooterView = footerView
            self.topHeadingTableView.frame = self.ViewFrame
              //XXX: 테이블이 사라짐
//            self.view.addSubview(self.everythingTableView)
        }
    
    //offset이 2번이면 기사를 더 가져옴
    func applyInternational(_ savedCountryCode: String, _ offset: Int){
        //이미지가 다운되는동안 request
        startAnimating(CGSize(width: 30.0, height: 30.0), message: "Loadding",
                       type: NVActivityIndicatorType.ballPulse, fadeInAnimation: nil)
       
        service = NewsService()
        service?.fetchInternationalNews(countryCode: savedCountryCode, offset: offset) { (success, articles) in
           
            if !success { print("fail")
                DispatchQueue.main.async {
                //데이터를 받으면 response, MainThread에서 실행
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
                }
                return
            }
            guard let items = articles else { print("no data!"); return }
            
            if self.offset == 1 {
                self.internationalData = items
            } else {
                self.internationalData += self.internationalData
            }
            
             DispatchQueue.main.async {
                if articles?.count == 0 {
                    self.keywardAlert()
                }
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
        service?.fetchKeywordNews(keyword: searchedText) { (success, articles) in

            if !success { print("fail")
                DispatchQueue.main.async {
                //데이터를 받으면 response, MainThread에서 실행
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
                }
            }
            guard let items = articles else { print("no data!"); return}
            self.keywardData = items

            DispatchQueue.main.async {
                if articles?.count == 0 {
                    self.keywardAlert()
                }
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
    
    func keywardAlert(){
        let alertController = UIAlertController(title: "Result", message: "There is no Information", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
//    func button(){
//      let button = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
//        button.backgroundColor = .green
//        button.setTitle("Test Button", for: .normal)
//        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
//
//      self.view.addSubview(button)
//    }
//
//    @objc func buttonAction(sender: UIButton!) {
//        let controller = NewsDetailViewController()
//        controller.delegate = self
//        present(controller, animated: true, completion: nil)
//    }
    
    
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
        if tableView == sourceTableView {
            return
        }
        
        if tableView == topHeadingTableView {
            let urlString = internationalData[indexPath.row].url ?? ""
            if let url = URL(string: urlString){
                UIApplication.shared.open(url, options: [:])
            }
            
            print(internationalData[indexPath.row].urlToImage ?? "nil")
        }
        
        if tableView == everythingTableView {
            let urlString = keywardData[indexPath.row].url ?? ""
            if let url = URL(string: urlString){
                UIApplication.shared.open(url, options: [:])
            }
        }
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
            countryText.text = "What's News today in \(countryCode.uppercased())"
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
        
        //스크롤의 가장 아래로 내려갈때 데이터 갱신
        if (self.topHeadingTableView.contentOffset.y +
            self.topHeadingTableView.frame.size.height >
            self.topHeadingTableView.contentSize.height &&
            self.topHeadingTableView.isDragging && fetchingMore == true){
                self.fetchingMore = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.applyInternational(self.countryCode, 2)
                    self.topHeadingTableView.tableFooterView = UIView()
                    self.topHeadingTableView.reloadData()
                }
            }
    }
     
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        let height = scrollView.frame.size.height
//        let contentYoffset = scrollView.contentOffset.y
//        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
//        if distanceFromBottom < height {
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
////                let newsItems = (self.internationalData.count...self.internationalData.count + 20).map { index in index}
//                let newsItem = (self.article)
//                self.internationalData.append(newsItem)
//                self.fetchingMore = false
//                self.topHeadingTableView.reloadData()
//
//            })
//
//        }
//    }
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
        applyInternational(countryCode, 1)
        countryText.text = "Whta's News today in \(countryCode.uppercased())"
        createLoadingCell()
    }
}

//MARK: UISearchBarDelegate
extension MainViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchBarText = searchBar.text else { return }
        applyKeyword(searchBarText)
        searchBar.resignFirstResponder()
    }
}


