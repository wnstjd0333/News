//
//  ViewController.swift
//  News
//
//  Created by kimjunseong on 2020/02/12.
//  Copyright © 2020 kimjunseong. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var topHeading: UITableView!
    @IBOutlet weak var everything: UITableView!
    @IBOutlet weak var source: UITableView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var switchSegment: UISegmentedControl!
    
    @IBAction func switchViews(_ sender: UISegmentedControl) {
        let x = scrollView.frame.size.width * CGFloat(sender.selectedSegmentIndex)
        scrollView.setContentOffset(CGPoint(x: x, y:0), animated: true)
    }
    
    var newsData = [Article]()
    var newsSource = [Source]()
    var service : NewsService?
    
    var tag = 0
    var cellIdentifier = ""
        
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
        
        topHeading.rowHeight = UITableView.automaticDimension
        topHeading.estimatedRowHeight = 400
        everything.rowHeight = UITableView.automaticDimension
        everything.estimatedRowHeight = 400
        source.rowHeight = UITableView.automaticDimension
        source.estimatedRowHeight = 400
        
    }
    
    func checkTableView(_ tableView: UITableView) {
        switch tableView.tag {
        case 0:
            tag = 0
            cellIdentifier = "TopHeadingTableViewCell"
        case 1:
            tag = 1
            cellIdentifier = "EverythingTableViewCell"
        case 2:
            tag = 2
            cellIdentifier = "SourceTableViewCell"
        default:
            print("error")
        }
    }
}

//MARK: UITableViewDataSource
extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        checkTableView(tableView)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! NewsTableViewCell
        
        if cellIdentifier == "SourceTableViewCell" {
            cell.textLabel?.text = newsSource[indexPath.row].name
        }
        else {
            cell.textLabel?.text = newsData[indexPath.row].title
        }
        
        cell.textLabel?.textColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        checkTableView(tableView)
        if cellIdentifier == "SourceTableViewCell" {
            return newsSource.count
        } else {
            return newsData.count

        }
    }
}

//MARK: UITableViewDelegate
extension ViewController : UITableViewDelegate {
    
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
}

extension ViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let w = scrollView.frame.size.width
        let page = scrollView.contentOffset.x / w
        switchSegment.selectedSegmentIndex = Int(round(page))
    }

}


