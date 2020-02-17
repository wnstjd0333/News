//
//  ViewController.swift
//  News
//
//  Created by kimjunseong on 2020/02/12.
//  Copyright © 2020 kimjunseong. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var TableViewMain: UITableView!
    
    var newsData : Array<Dictionary<String, Any>>?
   
    func fetchNews() {
        let task = URLSession.shared.dataTask(with: URL(string: "https://newsapi.org/v2/top-headlines?country=kr&apiKey=1cbc735ec5564a2a8890343f5d23bc61")!){ (data, response, error) in
            
            if let dataJson = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: dataJson, options: []) as! Dictionary<String, Any>
                    
                    let articles = json["articles"] as! Array<Dictionary<String, Any>>
                    print(articles)
                    self.newsData = articles
                    
                    DispatchQueue.main.async{
                        self.TableViewMain.reloadData()
                    }
                }
                catch {}
            }
        }
        task.resume()
    }
    
    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        TableViewMain.delegate = self
        TableViewMain.dataSource = self
        fetchNews()
    }
}

//MARK: UITableViewDataSource
extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let news = newsData{
            tableView.estimatedRowHeight = 80
            tableView.rowHeight = UITableView.automaticDimension
            return news.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = TableViewMain.dequeueReusableCell(withIdentifier: "NewsTableViewCell", for: indexPath) as! NewsTableViewCell
        
        let idx = indexPath.row
        if let news = newsData {
            let row = news[idx]
            if let r = row as? Dictionary<String, Any> {
                if let title = r["title"] as? String {
                cell.LabelText.text = title
                }
            }
        }
                
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier, "NewsDetail" == id {
            if let controller = segue.destination as? NewsDetailController{
                if let news = newsData {
                    if let indexPath = TableViewMain.indexPathForSelectedRow{
                        let row = news[indexPath.row]
                        if let r = row as? Dictionary<String, Any> {
                            if let imageUrl = r["urlToImage"] as? String {controller.imageUrl = imageUrl}
                            if let desc = r["description"] as? String {controller.desc = desc}
                            
                        }
                    }

                }
            
            }
        }
    }

}

//MARK: UITableViewDelegate
extension ViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(identifier: "NewsDetailController") as! NewsDetailController
        
        if let news = newsData {
            let row = news[indexPath.row]
            if let r = row as? Dictionary<String, Any> {
                if let imageUrl = r["urlToImage"] as? String {controller.imageUrl = imageUrl}
                if let desc = r["description"] as? String {controller.desc = desc}
                
            }
        }
        showDetailViewController(controller, sender:nil)
    }
}
