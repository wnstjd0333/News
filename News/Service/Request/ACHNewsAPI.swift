//
//  ACHNewsAPI.swift
//  News
//
//  Created by j.lee on 2020/02/17.
//  Copyright © 2020 archive-asia. All rights reserved.
//

import Foundation

final class ACHNewsAPI {
    
    static let apiKey = "52d80fad4fce4ac3bfaa4d428d0eccbd"
    
    struct InternationalNews : ACHNewsRequest {
        
        let country: String?
        var page: Int
        var pageSize: Int
        
        typealias Response = NewsResponse<Article>
        
        var method: HTTPMethod {
            return .get
        }
        
        var path: String {
            return "/v2/top-headlines"
        }
        
        var queryItems: [URLQueryItem] {
            return [
                URLQueryItem(name: "apiKey", value: apiKey),
                URLQueryItem(name: "country", value: country),
                URLQueryItem(name: "pageSize", value: String(pageSize)),
                URLQueryItem(name: "page", value: String(page))]
        }
    }
    
    struct KeywordNewsRequest : ACHNewsRequest {

        let keyword: String
        var page: Int
        var pageSize: Int
        
        typealias Response = NewsResponse<Article>

        var method: HTTPMethod {
            return .get
        }

        var path: String {
            return "/v2/everything"
        }

        var queryItems: [URLQueryItem] {
            return [
                URLQueryItem(name: "q", value: keyword),
                URLQueryItem(name: "apiKey", value: apiKey),
                URLQueryItem(name: "pageSize", value: String(pageSize)),
                URLQueryItem(name: "page", value: String(page))]
        }
    }
    
    struct NewsProviderRequest : ACHNewsRequest {
        
        typealias Response = NewsProviderResponse<Source>

        var method: HTTPMethod {
            return .get
        }

        var path: String {
            return "/v2/sources"
        }

        var queryItems: [URLQueryItem] {
            return [
                URLQueryItem(name: "apiKey", value: apiKey)]
        }
    }
    
    //TODO: Add request struct
}
