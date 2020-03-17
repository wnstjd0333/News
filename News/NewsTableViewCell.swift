//
//  Type1.swift
//  News
//
//  Created by kimjunseong on 2020/02/12.
//  Copyright © 2020 kimjunseong. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class NewsTableViewCell: UITableViewCell, NVActivityIndicatorViewable{
        
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var newsDescriptionLabel: UILabel!
    @IBOutlet weak var publishedAtLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var urlToImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var sourceDescription: UILabel!
        
    func startAnimation(){
        DispatchQueue.main.async {
            NVActivityIndicatorPresenter.sharedInstance.startAnimating(.init(size: CGSize(width: 30.0, height: 30.0), message: "Lodding", type: NVActivityIndicatorType.ballClipRotate, color: .blue, minimumDisplayTime: 1, backgroundColor: .brown, textColor: .cyan))
             NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
        }
    }
}
