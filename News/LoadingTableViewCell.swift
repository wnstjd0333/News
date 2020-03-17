//
//  LoadingTableViewCell.swift
//  News
//
//  Created by kimjunseong on 2020/03/17.
//  Copyright © 2020 kimjunseong. All rights reserved.
//

import UIKit

class LoadingTableViewCell: UITableViewCell {

    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    func startAnimating(){
        indicatorView.startAnimating()
    }
    
}
