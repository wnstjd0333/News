//
//  NewsDetailViewController.swift
//  News
//
//  Created by kimjunseong on 2020/03/03.
//  Copyright © 2020 kimjunseong. All rights reserved.
//

import UIKit

class NewsDetailViewController: UIViewController {
 
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var bodyTextView: UITextView!
           
    var publishedAt: String?
    var newsTitle: String?
    var content: String?
    var author: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeLabel.text = publishedAt
        headingLabel.text = newsTitle
        bodyTextView.text = content
        authorLabel.text = author
        
    }

    
    func clearView() {
        timeLabel.text  = ""
        headingLabel.text = ""
        bodyTextView.text = ""
        authorLabel.text = ""
    }
    
}

//MARK: - Actions
extension NewsDetailViewController {
        
    @IBAction func closeButtonTouched(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
}
