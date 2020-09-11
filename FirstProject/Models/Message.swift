//
//  Message.swift
//  FirstProject
//
//  Created by FirstProject on 18.09.2017.
//  Copyright © 2017 AtillaOzder. All rights reserved.
//

import Foundation

class Message {
    var date: Date?
    var text: String?
    var isSender: Bool?
    
    init(text: String, isSender: Bool) {
        self.date = Date()
        self.text = text
        self.isSender = isSender
    }
}
