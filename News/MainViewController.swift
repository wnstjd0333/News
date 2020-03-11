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
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var countryText: UILabel!
    @IBOutlet weak var topHeadingTableView: UITableView!
    @IBOutlet weak var everythingTableView: UITableView!
    @IBOutlet weak var sourceTableView: UITableView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var newsSegmentControl: UISegmentedControl!
    @IBOutlet weak var MainPageControl: UIPageControl!
    @IBOutlet weak var toSelectCountryButton: UIButton!
    
    var internationalData = [Article]()
    var keywardData = [Article]()
    var providerData = [Source]()
    var service : NewsService?
    var countryCode = "us"
    var searchedText = "corona"
    
    //MARK: action
    @IBAction func newsSwitchControlTapped(_ sender: UISegmentedControl) {
        
        let x = Int(mainScrollView.frame.size.width * CGFloat(sender.selectedSegmentIndex))
        mainScrollView.setContentOffset(CGPoint(x: x, y:0), animated: false)
        
        if newsSegmentControl.selectedSegmentIndex == 0 {
            topHeadingTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            toSelectCountryButton.alpha = 1
            searchBar.alpha = 0
            countryText.text = "Whta's News today in \(countryCode.uppercased())"
            
        } else if newsSegmentControl.selectedSegmentIndex == 1 {
            if keywardData.count == 0 {
                return
            } else {
            everythingTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
            toSelectCountryButton.alpha = 0
            searchBar.alpha = 1
            countryText.text = ""

        } else {
            sourceTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            toSelectCountryButton.alpha = 0
            searchBar.alpha = 0
            countryText.text = "List of News source"

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
        
        applyInternational(countryCode)
        applyKeyword(searchedText)
        applyNewsProvider()
    }
    
    func applyInternational(_ savedCountryCode: String){
        service = NewsService()
        
        startAnimating(CGSize(width: 30.0, height: 30.0), message: "Loadding", type: NVActivityIndicatorType.ballPulse, fadeInAnimation: nil)
        
        service?.fetchInternationalNews(countryCode: savedCountryCode) { (success, articles) in
             
             NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
             
            if !success { print("fail"); return }
            guard let items = articles else { print("no data!"); return }
             
            self.internationalData = items
            
             DispatchQueue.main.async {
                 self.topHeadingTableView.reloadData()
             }
         }
    }
    
    func applyKeyword(_ searchedText : String){
        service = NewsService()
        startAnimating(CGSize(width: 30.0, height: 30.0), message: "Loadding", type: NVActivityIndicatorType.ballPulse, fadeInAnimation: nil)
        
        service?.fetchKeywordNews(keyword: searchedText) { (success, articles) in
            
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)

            if !success { print("fail"); return}
            
            guard let items = articles else { print("no data!"); return}
                    
            self.keywardData = items

            DispatchQueue.main.async {
                if articles?.count == 0 {
                    self.keywardAlert()
                }
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
}

//MARK: UITableViewDataSource
extension MainViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellIndentifier = checkTableView(tableView)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIndentifier, for: indexPath) as! NewsTableViewCell
        
        if cellIndentifier == "TopHeadingTableViewCell" {
            
            cell.titleLabel.text           = internationalData[indexPath.row].title
            cell.publishedAtLabel.text     = internationalData[indexPath.row].publishedAt
            cell.sourceLabel.text          = internationalData[indexPath.row].author ?? "익명"
            cell.newsDescriptionLabel.text = internationalData[indexPath.row].description
            
            let remoteImageURL = URL(string: internationalData[indexPath.row].urlToImage ?? "error")

            cell.urlToImage?.sd_setImage(with: remoteImageURL, completed: {(downloadedImage, downloadException, cacheType, downloadURL) in

                if let downloadException = downloadException {
                    print("Error downloading the image: \(downloadException.localizedDescription)")
                }
            })
            
        } else if cellIndentifier == "EverythingTableViewCell"  {
            
            cell.titleLabel.text           = keywardData[indexPath.row].title
            cell.publishedAtLabel.text     = keywardData[indexPath.row].publishedAt
            cell.sourceLabel.text          = keywardData[indexPath.row].author ?? "익명"
            cell.newsDescriptionLabel.text = keywardData[indexPath.row].description
            
            let remoteImageURL = URL(string: keywardData[indexPath.row].urlToImage ?? "Error")
            cell.urlToImage?.sd_setImage(with: remoteImageURL, completed: {(downloadedImage, downloadException, cacheType, downloadURL) in
                           
                if let downloadException = downloadException {
                    
                print("Error downloading the image: \(downloadException.localizedDescription)")
                
                }
            })
 
        } else {
            cell.nameLabel.text = providerData[indexPath.row].name
            cell.sourceDescription.text = providerData[indexPath.row].description
            cell.languageLabel.text = "Language: " + (providerData[indexPath.row].language ?? "")
            cell.countryLabel.text  = "Country: " + (providerData[indexPath.row].country ?? "")
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
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(identifier: "NewsDetailViewController") as! NewsDetailViewController
        
        if tableView == sourceTableView {
            return
        }
        controller.delegate = self
        present(controller, animated: true, completion: nil)
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

extension MainViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = mainScrollView.frame.size.width
        let fractionalPage = mainScrollView.contentOffset.x / pageWidth
        MainPageControl.currentPage = Int(fractionalPage)
        
        if MainPageControl.currentPage == 0 {
            newsSegmentControl.selectedSegmentIndex = 0
            toSelectCountryButton.alpha = 1
            searchBar.alpha = 0
            countryText.text = "Whta's News today in \(countryCode.uppercased())"

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
        }
    }
}

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

extension MainViewController : CountryCollectionControllerDelegate {
    func countryApplyToService(_ savedCountryCode: String) {
        countryCode = savedCountryCode
        applyInternational(countryCode)
        countryText.text = "Whta's News today in \(countryCode.uppercased())"
    }
}

extension MainViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchBarText = searchBar.text else { return }
        applyKeyword(searchBarText)
        
    }
}

