//
//  UITableViewExtension.swift
//  News
//
//  Created by kimjunseong on 2020/03/17.
//  Copyright © 2020 kimjunseong. All rights reserved.
//

import UIKit

extension UITableView {
    func register<T: UITableViewCell>(cellType: T.Type) {
        let className = cellType.className
        let nib = UINib(nibName: className, bundle: nil)
        register(nib, forCellReuseIdentifier: className)
    }
    
    func register<T: UITableViewCell>(cellTypes: [T.Type]) {
        cellTypes.forEach { register(cellType: $0) }
    }
    
    func dequeueReusableCell<T: UITableViewCell>(with type: T.Type, for indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withIdentifier: type.className, for: indexPath) as! T
    }
}

extension NSObject{
    class var className: String {
        return String(describing: self)
    }
    
    var className: String {
        return type(of: self).className
    }
    
}
