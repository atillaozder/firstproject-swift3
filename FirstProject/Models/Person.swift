//
//  Person.swift
//  FirstProject
//
//  Created by AtillaOzder on 21.03.2017.
//  Copyright © 2017 AtillaOzder. All rights reserved.
//

import ObjectMapper

final class Person: Mappable {
    
    // MARK: - Stored Properties
    
    fileprivate var _id: Int?
    fileprivate var _username: String?
    fileprivate var _isOnline: Bool?
    fileprivate var _age: Int?
    fileprivate var _gender: String?
    fileprivate var _choice: String?
    fileprivate var _callCount: Int?
    fileprivate var _isActive: Bool?
    fileprivate var _isNameChanged: Bool?
    fileprivate var _isBanned: Bool?
    fileprivate var _friends: [Person] = Array()
    
    // MARK: - Computed Properties
    
    var id: Int {
        get {
            return _id!
        }
    }
    
    var username: String {
        get {
            return _username!
        }
        set {
            _username = newValue
        }
    }
    
    var isOnline: Bool {
        get {
            return _isOnline!
        }
        set {
            _isOnline = newValue
        }
    }
    
    var age: Int {
        get {
            return _age!
        }
        set {
            _age = newValue
        }
    }
    
    var gender: String {
        get {
            return _gender!
        }
    }
    
    var choice: String {
        get {
            return _choice!
        }
        set {
            _choice = newValue
        }
    }
    
    var callCount: Int {
        get {
            return _callCount!
        }
    }
    
    var isActive: Bool {
        get {
            return _isActive!
        }
        set {
            _isActive = newValue
        }
    }
    
    var isNameChanged: Bool {
        get {
            return _isNameChanged!
        }
        set {
            _isNameChanged = newValue
        }
    }
    
    var isBanned: Bool {
        get {
            return _isBanned!
        }
    }
    
    // MARK: - Constructor
    
    init() { }
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        _id            <- map["id"]
        _username      <- map["username"]
        _isOnline      <- map["isOnline"]
        _age           <- map["age"]
        _gender        <- map["gender"]
        _choice        <- map["match"]
        _callCount     <- map["call_number"]
        _isActive      <- map["is_active"]
        _isNameChanged <- map["is_username_changed"]
        _isBanned      <- map["is_banned"]
    }
    
    func getFriends() -> [Person] {
        return _friends
    }
    
    func addFriend(friend: Person) {
        _friends.append(friend)
    }
    
    func removeFriend(at index: Int) {
        _friends.remove(at: index)
    }
    
    func arrangeFriends() {
        _friends = _friends.sorted { $0._isOnline! && !$1._isOnline! }
    }
    
    // MARK: - toString
    
    func toString() -> String {
        return "Person: { ID: \(String(describing: _id)), Username: \(String(describing: _username)), Online Status: \(String(describing: _isOnline)), Age: \(String(describing: _age)), Gender: \(String(describing: _gender)), isActive: \(String(describing: _isActive)), isBanned: \(String(describing: _isBanned)), Call Number: \(String(describing: _callCount)), Choice: \(String(describing: _choice)) }"
    }
}

extension Person: Equatable {
    static func == (lhs: Person, rhs: Person) -> Bool {
        return
            lhs._id == rhs._id &&
                lhs._username == rhs._username &&
                lhs._isOnline == rhs._isOnline &&
                lhs._age == rhs._age &&
                lhs._gender == rhs._gender &&
                lhs._choice == rhs._choice &&
                lhs._callCount == rhs._callCount &&
                lhs._isActive == rhs._isActive &&
                lhs._isNameChanged == rhs._isNameChanged &&
                lhs._isBanned == rhs._isBanned
    }
}
