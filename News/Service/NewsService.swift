//
//  NewsService.swift
//  News
//
//  Created by P1506 on 2020/02/18.
//  Copyright © 2020 kimjunseong. All rights reserved.
//

import Foundation

class NewsService {
    
    func fetchInternationalNews(countryCode: String, completion: @escaping (Bool, [Article]?)->Void) {
        
        let client = ACHNewsClient()
        let request = ACHNewsAPI.InternationalNews(country: countryCode)
        
        client.send(request: request) { result in
            switch result {
            case let .success(response):
                completion(true, response.articles)
                
            case let .failure(error):
                print(error)
                completion(false, nil)
            }
        }
    }
}
