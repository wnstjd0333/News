//
//  Source.swift
//  News
//
//  Created by j.lee on 2020/02/21.
//  Copyright © 2020 archive-asia. All rights reserved.
//

import Foundation

struct Source : Decodable {
    
    let id: String?
    let name: String?
    let description: String?
    let url: String?
    let category: String?
    let language: String?
    let country: String?
}

