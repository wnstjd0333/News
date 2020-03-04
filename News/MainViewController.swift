//
//  ViewController.swift
//  News
//
//  Created by kimjunseong on 2020/02/12.
//  Copyright © 2020 kimjunseong. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
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
    
    //MARK: action
    @IBAction func newsSwitchControlTapped(_ sender: UISegmentedControl) {
        
        let x = Int(mainScrollView.frame.size.width * CGFloat(sender.selectedSegmentIndex))
        mainScrollView.setContentOffset(CGPoint(x: x, y:0), animated: false)
        
        if newsSegmentControl.selectedSegmentIndex == 0 {
            topHeadingTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            
        } else if newsSegmentControl.selectedSegmentIndex == 1 {
            everythingTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        
        } else {
            sourceTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }
    
    @IBAction func countryButtonClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "Country", sender: nil)
    }

    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topHeadingTableView.delegate = self
        topHeadingTableView.dataSource = self
        everythingTableView.delegate = self
        everythingTableView.dataSource = self
        sourceTableView.delegate = self
        sourceTableView.dataSource = self
        mainScrollView.delegate = self
              
        mainScrollView.isPagingEnabled = true
        
        service = NewsService()
        service?.fetchInternationalNews(countryCode: "kr") { (success, articles) in
            if !success { print("fail")
                return
            }
            
            guard let items = articles else { print("no data!")
                return
            }
            
            self.internationalData = items

            DispatchQueue.main.async {
                self.topHeadingTableView.reloadData()
            }
        }
        
        service?.fetchKeywordNews(keyword: "bitcoin") { (success, articles) in
            if !success { print("fail")
                return
            }
                    
            guard let items = articles else { print("no data!")
                return
            }
                    
            self.keywardData = items

            DispatchQueue.main.async {
                self.everythingTableView.reloadData()
            }
        }
        
        service?.fetchNewsProviders { (success, sources) in
            if !success { print("fail")
                return
            }
                    
            guard let items = sources else { print("no data!")
                return
            }
    
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
}

//MARK: UITableViewDataSource
extension MainViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIndentifier = checkTableView(tableView)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIndentifier, for: indexPath) as! NewsTableViewCell
        
        if cellIndentifier == "TopHeadingTableViewCell" {
            cell.titleLabel.text = internationalData[indexPath.row].title
            cell.publishedAtLabel.text = internationalData[indexPath.row].publishedAt
        
        //TODO : Article의 구조체 Source의 이름 불러오기
            cell.sourceLabel.text =  "   " + (internationalData[indexPath.row].author ?? "익명")
            cell.newsDescriptionLabel.text = internationalData[indexPath.row].description
            
            if let data = try? Data(contentsOf:
                URL(string: internationalData[indexPath.row].urlToImage ?? "nil")!){                        cell.urlToImage.image = UIImage(data: data)
                
        //TODO : 이미지 중복 불림 해결하기.
                
//            if cell.finishReload == false {
//                cell.finishReload = true
//                topHeadingTableView.beginUpdates()
//                topHeadingTableView.reloadRows(at: [IndexPath.init(row: indexPath.row, section: 0)], with: UITableView.RowAnimation.automatic)
//                topHeadingTableView.endUpdates()
//                }
            }
            

        } else if cellIndentifier == "EverythingTableViewCell"  {
            cell.titleLabel.text = keywardData[indexPath.row].title
            cell.publishedAtLabel.text = keywardData[indexPath.row].publishedAt
            cell.sourceLabel.text =  "   " + (keywardData[indexPath.row].author ?? "익명")
            cell.newsDescriptionLabel.text = keywardData[indexPath.row].description
            if let data = try? Data(contentsOf:
            URL(string: keywardData[indexPath.row].urlToImage ?? "nil")!){                        cell.urlToImage.image = UIImage(data: data)
            }

        } else {
            cell.nameLabel.text = providerData[indexPath.row].name
            cell.sourceDescription.text = providerData[indexPath.row].description
            cell.languageLabel.text = "Language: " + (providerData[indexPath.row].language ?? "")
            cell.countryLabel.text = "Country: " + (providerData[indexPath.row].country ?? "")
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

        } else if MainPageControl.currentPage == 1 {
            newsSegmentControl.selectedSegmentIndex = 1

        } else {
            newsSegmentControl.selectedSegmentIndex = 2
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
