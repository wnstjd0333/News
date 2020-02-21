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
    var service : NewsService?
    
    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topHeading.delegate = self
        topHeading.dataSource = self
        scrollView.delegate = self
              
        print("1111")
        //TODO: API로 취득하는 뉴스취득처리를 분리하여 서비스로 만들었습니다. 요걸로 바꿔주세요
        service = NewsService()
        service?.fetchInternationalNews(countryCode: "kr") { (success, articles) in
            print("2222")
            
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
        print("3333")
    }
}

//MARK: UITableViewDataSource
extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = topHeading.dequeueReusableCell(withIdentifier: "NewsTableViewCell") as! NewsTableViewCell
        cell.LabelText.text = newsData[indexPath.row].title
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
