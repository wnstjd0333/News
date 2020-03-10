//
//  CountryCollectionViewController.swift
//  News
//
//  Created by kimjunseong on 2020/03/04.
//  Copyright © 2020 kimjunseong. All rights reserved.
//

import UIKit

protocol CountryCollectionControllerDelegate : class {
    func countryApplyToService(_ savedCountryCode: String)
}

class CountryCollectionViewController : UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
        
    let countries = ["ae", "ar", "au", "bg", "br", "ca", "ch", "cn", "co","uk"]
    
    let countryImages: [UIImage] = [
        UIImage(named: "united-arab-emirates")!,
        UIImage(named: "argentina")!,
        UIImage(named: "australia")!,
        UIImage(named: "bulgaria")!,
        UIImage(named: "brazil")!,
        UIImage(named: "canada")!,
        UIImage(named: "switzerland")!,
        UIImage(named: "china")!,
        UIImage(named: "colombia")!,
        UIImage(named: "united-kingdom")!
    ]
    
    var countryName = ""
    weak var delegate: CountryCollectionControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK: action
    @IBAction func cancelButtonTouched(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
    }
    @IBAction func selectButtonTouched(_ sender: Any) {
        delegate?.countryApplyToService(countryName)
        dismiss(animated: true, completion: nil)
    }
}

//MARK: UICollectionViewDelegate
extension CountryCollectionViewController : UICollectionViewDelegate {
    
}

//MARK: UICollectionViewDataSource
extension CountryCollectionViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return countries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CountryCollectionViewCell", for: indexPath) as! CountryCollectionViewCell
        
        cell.countryNameLabel.text = countries[indexPath.item]
        cell.countryImageView.image = countryImages[indexPath.item]
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 0.5
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CountryCollectionViewCell", for: indexPath) as! CountryCollectionViewCell
        
        cell = collectionView.cellForItem(at: indexPath) as! CountryCollectionViewCell
        cell.layer.borderColor = UIColor.gray.cgColor
        cell.layer.borderWidth = 2
        countryName = countries[indexPath.row]
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderColor = UIColor.lightGray.cgColor
        cell?.layer.borderWidth = 0.5
    }
}
