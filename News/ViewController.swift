//
//  ViewController.swift
//  News
//
//  Created by kimjunseong on 2020/02/12.
//  Copyright © 2020 kimjunseong. All rights reserved.
//

import TinyConstraints

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
    }
    
    func checkTableView(_ tableView: UITableView) {
        if tableView.tag == 0 {
            tag = 0
            cellIdentifier = "TopHeadingTableViewCell"
        }
        else if tableView.tag == 1 {
            tag = 1
            cellIdentifier = "EverythingTableViewCell"
        }
        else if tableView.tag == 2{
            tag = 2
            cellIdentifier = "SourceTableViewCell"
        }
    }
}

//MARK: UITableViewDataSource
extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        checkTableView(tableView)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath as IndexPath)
        
        if cellIdentifier == "SourceTableViewCell" {
            cell.textLabel?.text = newsSource[indexPath.row].name
            
        } else {
            cell.textLabel?.text = newsData[indexPath.row].title

        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        checkTableView(tableView)
        if cellIdentifier == "SourceTableViewCell" {
            return newsSource.count
        }
        
        return newsData.count
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
