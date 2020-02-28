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
    
    @IBAction func newsSwitchControlTapped(_ sender: UISegmentedControl) {
        
//        let x = mainScrollView.frame.size.width * CGFloat(sender.selectedSegmentIndex)
//        mainScrollView.setContentOffset(CGPoint(x: x, y:0), animated: true)
    }
    
    var internationalData = [Article]()
    var providerData = [Source]()
    var service : NewsService?
    
    var tag = 0
        
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
            if !success {
                print("fail")
                return
            }
            
            guard let items = articles else {
                print("no data!")
                return
            }
            
            self.internationalData = items

            DispatchQueue.main.async {
                self.topHeadingTableView.reloadData()
               
            }
        }
        
        service?.fetchKeywordNews(keyword: "bitcoin") { (success, articles) in
            if !success {
                print("fail")
                return
            }
                    
            guard let items = articles else {
                print("no data!")
                return
            }
                    
            self.internationalData = items

            DispatchQueue.main.async {
                self.everythingTableView.reloadData()
            }
        }
        
        service?.fetchNewsProviders { (success, sources) in
            if !success {
                print("fail")
                return
            }
                    
            guard let items = sources else {
                print("no data!")
                return
            }
    
            self.providerData = items
            
            DispatchQueue.main.async {
                self.sourceTableView.reloadData()
            }
        }
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier, "NewsDetail" == id {
            if let controller = segue.destination as? NewsDetailController{
                if let indexPath = topHeadingTableView.indexPathForSelectedRow{
                    let row = internationalData[indexPath.row]
                    controller.imageUrl = row.urlToImage
                    controller.desc = row.description
                }
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
        
        if newsSegmentControl.selectedSegmentIndex == 2 {
            cell.contentTextLabel.text = providerData[indexPath.row].name

        } else if newsSegmentControl.selectedSegmentIndex == 1{
            cell.contentTextLabel.text = internationalData[indexPath.row].title

        } else if newsSegmentControl.selectedSegmentIndex == 0{
            cell.contentTextLabel.text = internationalData[indexPath.row].title
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if newsSegmentControl.selectedSegmentIndex == 2 {
            return providerData.count
        } else if newsSegmentControl.selectedSegmentIndex == 1{
            return internationalData.count
        } else {
            return internationalData.count
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

extension MainViewController : UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        let pageWidth = self.mainScrollView.frame.size.width
//        let fractionalPage = Double(self.mainScrollView.contentOffset.x / pageWidth)
//        let page = lround(fractionalPage)
//        self.MainPageControl.currentPage = page
//
//        if MainPageControl.currentPage == 0{
//            newsSegmentControl.selectedSegmentIndex = 0
//            topHeadingTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
//
//        } else if MainPageControl.currentPage == 1 {
//            newsSegmentControl.selectedSegmentIndex = 1
//            everythingTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
//
//        } else {
//            newsSegmentControl.selectedSegmentIndex = 2
//            sourceTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
//        }
//    }
}


