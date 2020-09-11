//
//  NetworkManager.swift
//  FirstProject
//
//  Created by AtillaOzder on 27.04.2017.
//  Copyright © 2017 AtillaOzder. All rights reserved.
//

import Alamofire
import RxCocoa
import RxSwift
import ObjectMapper
import SwiftyJSON
import FBSDKCoreKit

fileprivate var networkManager: Alamofire.SessionManager!

final class NetworkManager {
    
    // MARK: - Properties
    
    static let baseURL: String = "https://www.AtillaOzder.com"
    static let tokenURL: String = baseURL + "/register/facebook/?access_token=" + FBSDKAccessToken.current().tokenString!
    static let getURL: String = baseURL + "/users/" + FBSDKAccessToken.current().userID! + "/"
    static let patchURL: String = getURL + "edit/"
    static let deleteURL: String = baseURL + "/friendship/delete/?user="
    static let privacyURL: String = baseURL + "/privacy/"
    static let termsURL: String = baseURL + "/terms/"
    static let licencesURL: String = baseURL + "/licences/"
    
    static let sharedManager: NetworkManager = NetworkManager()
    
    // MARK: - Constructor
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        networkManager = SessionManager(configuration: configuration)
        NetworkManager.setHTTPHeaders()
    }
    
    // MARK: - AccessToken HTTP Headers
    
    static func setHTTPHeaders() {
        do {
            if let accessToken = try AppDelegate.keychain.get("accessToken") {
                networkManager.adapter = NetworkAdapter(accessToken: accessToken)
                networkManager.retrier = NetworkAdapter(accessToken: accessToken)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Token Request
    
    func tokenRequest() -> Observable<JSON> {
        
        return Observable.create { (observer) -> Disposable in
            
            let request = Alamofire.request(NetworkManager.tokenURL).responseJSON { (response) in
                
                switch response.result {
                    
                case .success(let value):
                    
                    let json = JSON(value)
                    
                    observer.onNext(json)
                    observer.onCompleted()
                    
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create {
                return request.cancel()
            }
        }
    }
    
    // MARK: - Get Request
    
    func getRequest() -> Observable<Person?> {
        
        return Observable.create { (observer) -> Disposable in
            
            let request = networkManager.request(NetworkManager.getURL).responseJSON { (response) in
                
                switch response.result {
                case .success(let value):
                    
                    if response.response?.statusCode == 401 {
                        let error = NSError(domain: NetworkManager.getURL, code: 401, userInfo: nil)
                        observer.onError(error)
                        
                    } else {
                        
                        let json = JSON(value)
                        let jsonString = json.rawString()
                        let person = Person(JSONString: jsonString!)
                        
                        for element in json["friend_id"].array! {
                            let model = Person(JSONString: element["user_id"].rawString()!)
                            person?.addFriend(friend: model!)
                        }
                        
                        for element in json["user_id"].array! {
                            let model = Person(JSONString: element["friend_id"].rawString()!)
                            person?.addFriend(friend: model!)
                        }
                        
                        person?.arrangeFriends()
                        observer.onNext(person)
                        observer.onCompleted()
                        
                    }
                    
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    // MARK: - Patch Request
    
    func patchRequest(person: Person) -> Observable<AnyObject?> {
        
        let parameters = person.toJSON()
        
        return Observable.create { (observer) -> Disposable in
            
            let request = networkManager.request(NetworkManager.patchURL, method: .patch, parameters: parameters, encoding: JSONEncoding.default).responseJSON { (response) in
                
                switch response.result {
                case .success(let value):
                    
                    if response.response?.statusCode == 401 {
                        
                        let error = NSError(domain: NetworkManager.patchURL, code: 401, userInfo: nil)
                        observer.onError(error)
                        
                    } else if response.response?.statusCode == 400 {
                        
                        let error = NSError(domain: NetworkManager.patchURL, code: 400, userInfo: nil)
                        observer.onError(error)
                        
                    } else {
                        
                        let jsonString = JSON(value).rawString()
                        let person = Person(JSONString: jsonString!)
                        observer.onNext(person)
                        observer.onCompleted()
                        
                    }
                    
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    // MARK: - Delete Request
    
    func deleteRequest(URL: String) -> Observable<AnyObject?> {
        
        return Observable.create { (observer) -> Disposable in
            
            let request = networkManager.request(NetworkManager.deleteURL + URL).responseString { (response) in
                
                switch response.result {
                case .success:
                    
                    if response.response?.statusCode == 401 {
                        let error = NSError(domain: NetworkManager.getURL, code: 401, userInfo: nil)
                        observer.onError(error)
                        
                    } else {
                        
                        observer.onNext(nil)
                        observer.onCompleted()
                        
                    }
                    
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
}
