//
//  ViewController.swift
//  News
//
//  Created by kimjunseong on 2020/02/12.
//  Copyright © 2020 kimjunseong. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    //ManiViewController
    @IBOutlet weak var topHeading: UITableView!
    //topHeadingTableView
    @IBOutlet weak var everything: UITableView!
    @IBOutlet weak var source: UITableView!
    
    @IBOutlet weak var scrollView: UIScrollView!
//    mainScrollView
    
    @IBOutlet weak var switchSegment: UISegmentedControl!
//    newsSegmentControl
    
    @IBAction func switchViews(_ sender: UISegmentedControl) {
//        switchControlTouched()
//        newsSwitchControlTapped(_ sender)
        
        let x = scrollView.frame.size.width * CGFloat(sender.selectedSegmentIndex)
        scrollView.setContentOffset(CGPoint(x: x, y:0), animated: true)
    }
    
    var newsData = [Article]()
    var newsSource = [Source]()
    var service : NewsService?
    
    var tag = 0
//    var cellIdentifier = ""
        
    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topHeading.delegate = self
        topHeading.dataSource = self
        everything.delegate = self
        everything.dataSource = self
        source.delegate = self
        source.dataSource = self
        scrollView.delegate = self
              
        scrollView.isPagingEnabled = true
        
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
            
            self.newsData = items
            
//            for article in items {
//                print(article.author)
//            }

            DispatchQueue.main.async {
                self.topHeading.reloadData()
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
                    
            self.newsData = items

            DispatchQueue.main.async {
                self.everything.reloadData()
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
            
            self.newsSource = items
            
            DispatchQueue.main.async {
                self.source.reloadData()
            }
        }
        
//        topHeading.rowHeight = UITableView.automaticDimension
//        topHeading.estimatedRowHeight = 400
//        everything.rowHeight = UITableView.automaticDimension
//        everything.estimatedRowHeight = 400
//        source.rowHeight = UITableView.automaticDimension
//        source.estimatedRowHeight = 400
        
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier, "NewsDetail" == id {
            if let controller = segue.destination as? NewsDetailController{
                if let indexPath = topHeading.indexPathForSelectedRow{
                    let row = newsData[indexPath.row]
                    controller.imageUrl = row.urlToImage
                    controller.desc = row.description
                }
            }
        }
    }
    
    func checkTableView(_ tableView: UITableView) -> String {
        if tableView == topHeading {
            return "TopHeadingTableViewCell"
        }else if tableView == everything {
            return "EverythingTableViewCell"
        }else {
            return "SourceTableViewCell"
        }
        
        return ""
        
    }
}

//MARK: UITableViewDataSource
extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIndentifier = checkTableView(tableView)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIndentifier, for: indexPath) as! NewsTableViewCell
        
        
        
        if switchSegment.selectedSegmentIndex == 2 {
            cell.contentTextLabel.text = newsSource[indexPath.row].name
        }else {
            cell.contentTextLabel.text = newsData[indexPath.row].title
        }
        
        //cell.textLabel?.textColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        checkTableView(tableView)
        if switchSegment.selectedSegmentIndex == 2 {
            return newsSource.count
        } else {
            return newsData.count

        }
    }
}

//MARK: UITableViewDelegate
extension ViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

extension ViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scrollViewDidScroll - \(scrollView.contentOffset.x)")
        if scrollView != self.scrollView {
            return
        }
        
        let w = scrollView.frame.size.width
        
        let page = scrollView.contentOffset.x / w
        print("scrollViewDidScroll - page \(page)")
        if page == 0 {
            switchSegment.selectedSegmentIndex = 0
        } else if page == 1 {
            switchSegment.selectedSegmentIndex = 1
        }else if page == 2 {
            switchSegment.selectedSegmentIndex = 2
        }
        
    }

}


