//
//  NewsDetailController.swift
//  News
//
//  Created by kimjunseong on 2020/02/17.
//  Copyright © 2020 kimjunseong. All rights reserved.
//

import UIKit

class NewsDetailController : UIViewController {
   
    @IBOutlet weak var ImageMain: UIImageView!
    @IBOutlet weak var LabelMain: UILabel!
    
    var imageUrl: String?
    var desc: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let img = imageUrl {
            if let data = try? Data(contentsOf: URL(string: img)!){
                //Main Thread
                DispatchQueue.main.async{
                self.ImageMain.image = UIImage(data: data)
                }
            }
        }
        if let description = desc {
            self.LabelMain.text = description
        }
    }
}
