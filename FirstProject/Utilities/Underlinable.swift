//
//  Underlinable.swift
//  FirstProject
//
//  Created by FirstProject on 12.09.2017.
//  Copyright © 2017 AtillaOzder. All rights reserved.
//

import UIKit

protocol Underlinable {
    func underline(mutableStr: NSMutableAttributedString, onRange range: NSRange, color: UIColor)
}

extension Underlinable where Self: UILabel {
    func underline(mutableStr: NSMutableAttributedString, onRange range: NSRange, color: UIColor) {
        mutableStr.addAttributes([
            NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue,
            NSUnderlineColorAttributeName: color
            ], range: range)
    }
}
