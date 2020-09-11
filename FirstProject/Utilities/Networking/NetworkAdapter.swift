//
//  NetworkAdapter.swift
//  FirstProject
//
//  Created by AtillaOzder on 27.04.2017.
//  Copyright © 2017 AtillaOzder. All rights reserved.
//

import Alamofire

final class NetworkAdapter: RequestAdapter, RequestRetrier {
    
    // MARK: - Properties
    
    private var accessToken: String
    private var requestsAndRetryCounts: [(Request, Int)] = []
    private let lock = NSLock()
    
    // MARK: - Constructor
    
    required init (accessToken: String) {
        self.accessToken = accessToken
    }
    
    private func index(request: Request) -> Int? {
        return requestsAndRetryCounts.index(where: { $0.0 === request })
    }
    
    // MARK: - RequestAdapter, RequestRetrier
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        return urlRequest
    }
    
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        lock.lock(); defer { lock.unlock() }
        guard let index = index(request: request) else { completion(false, 0); return }
        let (request, retryCount) = requestsAndRetryCounts[index]
        
        if retryCount == 0 {
            completion(false, 0)
        } else {
            requestsAndRetryCounts[index] = (request, retryCount - 1)
            completion(true, 0.5)
        }
    }
}
