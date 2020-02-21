//
//  NewsProviderResponse.swift
//  News
//
//  Created by j.lee on 2020/02/21.
//  Copyright © 2020 archive-asia. All rights reserved.
//

import Foundation

struct NewsProviderResponse<Item : Decodable> : Decodable {
    let status: String
    let sources: [Item]
    
    enum CodingKeys : String, CodingKey {
        case status
        case sources
    }
}
