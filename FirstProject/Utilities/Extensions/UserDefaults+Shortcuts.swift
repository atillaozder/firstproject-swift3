//
//  UserDefaults+Shortcuts.swift
//  FirstProject
//
//  Created by AtillaOzder on 25.04.2017.
//  Copyright © 2017 AtillaOzder. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    func getChoice() -> String {
        return string(forKey: "choice")!
    }
    
    func setChoice(value: String) {
        set(value, forKey: "choice")
        synchronize()
    }
    
    func getDate() -> Any? {
        return value(forKey: "expires_in")
    }
    
    func setDate(value: Any) {
        set(value, forKey: "expires_in")
        synchronize()
    }
}

extension Date {
    func add(seconds: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .second, value: seconds, to: self)!
    }
}
