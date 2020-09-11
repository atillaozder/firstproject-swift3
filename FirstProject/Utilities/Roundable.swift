//
//  Roundable.swift
//  FirstProject
//
//  Created by FirstProject on 10.09.2017.
//  Copyright © 2017 AtillaOzder. All rights reserved.
//

import UIKit

protocol Roundable {
    func setCornersRounded(withCornerRadius rad: CGFloat)
    func setCornersRounded()
    func setRounded()
}

extension Roundable where Self: UIView {
    
    func setCornersRounded(withCornerRadius rad: CGFloat) {
        layer.cornerRadius = rad
        clipsToBounds = true
    }
    
    func setCornersRounded() {
        layer.cornerRadius = self.frame.size.height / 2
        clipsToBounds = true
    }
    
    func setRounded() {
        layer.cornerRadius = frame.size.width / 2
        clipsToBounds = true
        if self.isKind(of: UIButton.self) {
            (self as! UIButton).imageView?.image = (self as! UIButton).imageView?.image?.withRenderingMode(.alwaysTemplate)
        }
    }
}
