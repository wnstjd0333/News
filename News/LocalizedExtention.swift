//
//  LocalizedExtention.swift
//  News
//
//  Created by kimjunseong on 2020/03/26.
//  Copyright © 2020 kimjunseong. All rights reserved.
//
import Foundation

extension String {
    func localizableString(_ country: String) -> String {
        if country == "us" {
            return NSLocalizedString(self, tableName: nil, bundle: Bundle(
                path: Bundle.main.path(forResource: "en", ofType: "lproj")!)!,
            value: "", comment: "")
        }
        
        if country == "jp" {
            return NSLocalizedString(self, tableName: nil, bundle: Bundle(
                path: Bundle.main.path(forResource: "ja", ofType: "lproj")!)!,
            value: "", comment: "")
        }
        
        if country == "kr" {
            return NSLocalizedString(self, tableName: nil, bundle: Bundle(
                path: Bundle.main.path(forResource: "ko", ofType: "lproj")!)!,
            value: "", comment: "")
        }
        
        if country == "ae" {
            return NSLocalizedString(self, tableName: nil, bundle: Bundle(
                path: Bundle.main.path(forResource: "ar-AE", ofType: "lproj")!)!,
            value: "", comment: "")
        }
        
        if country == "se" {
            return NSLocalizedString(self, tableName: nil, bundle: Bundle(
                path: Bundle.main.path(forResource: "sv", ofType: "lproj")!)!,
            value: "", comment: "")
        }
        
        if country == "ar" || country == "br" || country == "co" {
              return NSLocalizedString(self, tableName: nil, bundle: Bundle(
                path: Bundle.main.path(forResource: "es-419", ofType: "lproj")!)!,
              value: "", comment: "")
          }
        
        if country == "cn" {
            return NSLocalizedString(self, tableName: nil, bundle: Bundle(
                path: Bundle.main.path(forResource: "zh-HK", ofType: "lproj")!)!,
            value: "", comment: "")
        }
        
        if country == "ch" {
            return NSLocalizedString(self, tableName: nil, bundle: Bundle(
                path: Bundle.main.path(forResource: "de", ofType: "lproj")!)!,
            value: "", comment: "")
        }
        
        guard let path = Bundle.main.path(forResource: country, ofType: "lproj"),
        let bundle = Bundle(path: path) else {
            return NSLocalizedString(self, comment: "")
        }
        return NSLocalizedString(self, tableName: nil, bundle: bundle,
                                 value: "", comment: "")
    }
}
