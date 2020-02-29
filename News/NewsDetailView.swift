//
//  NewsDetailView.swift
//  News
//
//  Created by j.lee on 2020/02/28.
//  Copyright © 2020 archive-asia. All rights reserved.
//

import UIKit

class NewsDetailView: UIView {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var bodyTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // initailize UI code.
        
    }
    
    func configureView(_ model: Article) {
        
        //TODO: 표시 포멧을 적절히 변경하세요.
        
        timeLabel.text  = model.publishedAt
        headingLabel.text = model.title
        bodyTextView.contentOffset = .zero
        bodyTextView.text = model.content ?? model.description
        authorLabel.text = model.author
    }
    
    func clearView() {
        timeLabel.text  = ""
        headingLabel.text = ""
        bodyTextView.text = ""
        authorLabel.text = ""
    }

}
