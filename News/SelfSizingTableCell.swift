//
//  SelfSizingTableCell.swift
//  News
//
//  Created by kimjunseong on 2020/02/26.
//  Copyright © 2020 kimjunseong. All rights reserved.
//

import UIKit

class SelfSizingTableCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

