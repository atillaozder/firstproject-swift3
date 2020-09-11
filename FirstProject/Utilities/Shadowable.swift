//
//  Shadowable.swift
//  FirstProject
//
//  Created by FirstProject on 10.09.2017.
//  Copyright © 2017 AtillaOzder. All rights reserved.
//

import UIKit

protocol Shadowable {
    func addShadow()
}

extension Shadowable where Self: UIButton {
    func addShadow() {
        layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 0.25
        layer.shadowColor = UIColor.black.cgColor
        setShadowPath()
    }
}

extension Shadowable where Self: UIImageView {
    func addShadow() {
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        layer.shadowRadius = 5.0
        layer.shadowOpacity = 0.3
        layer.shadowColor = UIColor.black.cgColor
        setShadowPath()
    }
}

extension Shadowable where Self: UICollectionView {
    func addShadow() {
        layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        layer.shadowRadius = 3.0
        layer.shadowOpacity = 0.5
        layer.shadowColor = CustomColors.buyBtn.value.cgColor
        layer.masksToBounds = false
    }
}

extension Shadowable where Self: CallButton {
    func addShadow() {
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        layer.shadowRadius = 4.0
        layer.shadowOpacity = 0.3
        layer.shadowColor = UIColor.black.cgColor
        setShadowPath()
    }
}

extension Shadowable where Self: GetPlusButton {
    func addShadow() {
        layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        layer.shadowRadius = 3.0
        layer.shadowOpacity = 0.25
        layer.shadowColor = UIColor.darkGray.cgColor
        setShadowPath()
    }
}

fileprivate extension Shadowable where Self: UIView {
    func setShadowPath() {
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.masksToBounds = false
    }
}

