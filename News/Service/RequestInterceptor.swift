//
//  AuthorizationModel.swift
//  News
//
//  Created by kimjunseong on 2020/03/24.
//  Copyright © 2020 kimjunseong. All rights reserved.
//

import UIKit
import Alamofire

protocol AccessTokenStorage: class {
    typealias JWT = String
    var accessToken: JWT { get set }
}

final class RequestInterceptor: Alamofire.RequestInterceptor {

    private var baseURLString: String = "https://newsapi.org"
    var isRefreshing: Bool = false
    private let storage: AccessTokenStorage

    init(storage: AccessTokenStorage) {
        self.storage = storage
    }

    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        guard urlRequest.url?.absoluteString.hasPrefix(baseURLString) == true else {
            /// If the request does require authentication, we can directly return it as unmodified.
            return completion(.success(urlRequest))
        }
        var urlRequest = urlRequest

        /// Set the Authorization header value using the access token.
        urlRequest.setValue("Bearer " + storage.accessToken, forHTTPHeaderField: "Authorization")

        completion(.success(urlRequest))
    }

    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {

        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 else {
            /// The request did not fail due to a 401 Unauthorized response.
            /// Return the original error and don't retry the request.
            return completion(.doNotRetryWithError(error))
        }

        refreshToken { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let token):
                self.storage.accessToken = token
                /// After updating the token we can safily retry the original request.
                completion(.retry)
            case .failure(let error):
                completion(.doNotRetryWithError(error))
            }
        }
    }
    
    func refreshToken(completion: @escaping (Result<String, Error>) -> Void){
        guard !isRefreshing else { return }
        
        isRefreshing = true
        
        let urlString = "\(baseURLString)/oauth2/token"

        let parameters: [String: Any] = [
//            "access_token": accessToken,
//            "refresh_token": refreshToken,
//            "client_id": clientID,
//            "grant_type": "refresh_token"
            :]
        
        AF.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default) .responseJSON { [weak self] response in guard let strongSelf = self else { return }
        
//            if let json = response.result.value as? [String: Any],
//                let accessToken = json["access_token"] as? String,
//                let refreshToken = json["refresh_token"] as? String {
//
//                completion(true, accessToken, refreshToken)
//
//            } else {
//                completion(false, nil, nil)
//            }
            strongSelf.isRefreshing = false
        }
    }
}



//class RequestInterceptor: RequestAdapter, RequestRetrier {
//    private typealias RefreshCompletion = (_ succeeded: Bool, _ accessToken: String?, _ refreshToken: String?) -> Void
//    private let sessionManager: Session = {
//        let configuration = URLSessionConfiguration.default
//        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
//
//        return SessionManager(configuration: configuration)
//    }()
//
//    private let lock = NSLock()
//    private var clientID: String
//    private var baseURLString: String
//    private var accessToken: String
//    private var refreshToken: String
//    private var isRefreshing = false
//    private var requestsToRetry: [RequestRetryCompletion] = []
//
//    // MARK: - Initialization
//
//    public init(clientID: String, baseURLString: String, accessToken: String, refreshToken: String) {
//        self.clientID = clientID
//        self.baseURLString = baseURLString
//        self.accessToken = accessToken
//        self.refreshToken = refreshToken }
//
//    // MARK: - RequestAdapter
//
//    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
//        if let urlString = urlRequest.url?.absoluteString, urlString.hasPrefix(baseURLString) {
//            var urlRequest = urlRequest
//            urlRequest.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
//
//            return urlRequest
//        }
//        return urlRequest
//    }
//
//    // MARK: - RequestRetrier
//
//    func should(_ manager: Session, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) { lock.lock() ; defer { lock.unlock() }
//
//        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 {
//            requestsToRetry.append(completion)
//
//            if !isRefreshing {
//                refreshTokens { [weak self] succeeded, accessToken, refreshToken in
//                    guard let strongSelf = self else { return }
//
//                    strongSelf.lock.lock() ; defer { strongSelf.lock.unlock() }
//
//                    if let accessToken = accessToken, let refreshToken = refreshToken {
//                        strongSelf.accessToken = accessToken
//                        strongSelf.refreshToken = refreshToken
//                    }
//
//                    strongSelf.requestsToRetry.forEach { $0(succeeded, 0.0) }
//                    strongSelf.requestsToRetry.removeAll()
//                }
//            }
//        } else {
//            completion(false, 0.0) }
//    }
//
//    // MARK: - Private - Refresh Tokens
//    private func refreshTokens(completion: @escaping RefreshCompletion) {
//        guard !isRefreshing else { return }
//
//        isRefreshing = true
//
//        let urlString = "\(baseURLString)/oauth2/token"
//
//        let parameters: [String: Any] = [
//            "access_token": accessToken,
//            "refresh_token": refreshToken,
//            "client_id": clientID,
//            "grant_type": "refresh_token"
//        ]
//
//        sessionManager.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default) .responseJSON { [weak self] response in guard let strongSelf = self else { return }
//
//            if let json = response.result.value as? [String: Any],
//                let accessToken = json["access_token"] as? String,
//                let refreshToken = json["refresh_token"] as? String {
//
//                completion(true, accessToken, refreshToken)
//
//            } else {
//                completion(false, nil, nil)
//            }
//            strongSelf.isRefreshing = false
//        }
//    }
//}

