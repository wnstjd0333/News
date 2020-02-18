//
//  NewsResponse.swift
//  News
//
//  Created by j.lee on 2020/02/17.
//  Copyright © 2020 archive-asia. All rights reserved.
//

import Foundation

struct NewsResponse<Item : Decodable> : Decodable {
    let status: String
    let totalCount: Int
    let articles: [Item]
    
    enum CodingKeys : String, CodingKey {
        case status
        case totalCount = "totalResults"
        case articles
    }
}
