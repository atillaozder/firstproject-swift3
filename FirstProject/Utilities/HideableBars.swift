//
//  HideableBars.swift
//  FirstProject
//
//  Created by FirstProject on 11.09.2017.
//  Copyright © 2017 AtillaOzder. All rights reserved.
//

import UIKit

protocol HideableBars {
    func setTabBarHidden(animated: Bool)
    func isTabBarHidden() -> Bool
    func setNavBarHidden(animated: Bool)
    func isNavBarHidden() -> Bool
}

extension HideableBars where Self: CallVC {
    
    func setTabBarHidden(animated: Bool) {
        guard self.tabBarController != nil else { return }
        let hidden = !(isTabBarHidden())
        let height = self.tabBarController!.tabBar.frame.size.height
        let offsetY = (hidden ? -height : height)
        let duration = (animated ? 0.3 : 0.0)
        
        UIView.animate(withDuration: duration,
                       animations: {
                        let frame = self.tabBarController!.tabBar.frame
                        self.tabBarController?.tabBar.frame = frame.offsetBy(dx: 0, dy: offsetY)
        })
        
    }
    
    func isTabBarHidden() -> Bool {
        return self.tabBarController!.tabBar.frame.origin.y < self.view.frame.maxY
    }
    
    func setNavBarHidden(animated: Bool) {
        guard self.navigationController != nil else { return }
        let hidden = !(isNavBarHidden())
        let height = self.navigationController!.navigationBar.frame.size.height - (UIApplication.shared.statusBarFrame.height * 2)
        let offsetY = (hidden ? -height : height)
        let duration = (animated ? 0.3 : 0.0)
        
        UIView.animate(withDuration: duration,
                       animations: {
                        let frame = self.navigationController!.navigationBar.frame
                        self.navigationController!.navigationBar.frame = frame.offsetBy(dx: 0, dy: offsetY)
        })
        
    }
    
    func isNavBarHidden() -> Bool {
        return self.navigationController!.navigationBar.frame.origin.y < self.view.frame.minY
    }
}
