//
//  UIViewController+Utilities.swift
//  FirstProject
//
//  Created by FirstProject on 13.09.2017.
//  Copyright © 2017 AtillaOzder. All rights reserved.
//

import UIKit

extension UIViewController {
    func changeStatusBarVisibility(withDuration duration: TimeInterval) {
        AppDelegate.isStatusBarHidden = !(AppDelegate.isStatusBarHidden)
        UIView.animate(withDuration: duration) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
}

