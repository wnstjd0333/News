//
//  NewsService.swift
//  News
//
//  Created by j.lee on 2020/02/18.
//  Copyright © 2020 archive-asia. All rights reserved.
//

import Foundation

class NewsService {
    
    func fetchInternationalNews(countryCode: String, page: Int, pageSize: Int ,completion: @escaping (Bool, [Article]?)->Void) {
        
        let client = ACHNewsClient()
        let request = ACHNewsAPI.InternationalNews(country: countryCode, page: page, pageSize: pageSize)
        
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
    
    func fetchKeywordNews(keyword: String, completion: @escaping (Bool, [Article]?)->Void) {
        
        let client = ACHNewsClient()
        let request = ACHNewsAPI.KeywordNewsRequest(keyword: keyword)
        
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
    
    func fetchNewsProviders(completion: @escaping (Bool, [Source]?)->Void) {
        
        let client = ACHNewsClient()
        let request = ACHNewsAPI.NewsProviderRequest()
        
        client.send(request: request) { result in
            switch result {
            case let .success(response):
                completion(true, response.sources)
                
            case let .failure(error):
                print(error)
                completion(false, nil)
            }
        }
    }
}
