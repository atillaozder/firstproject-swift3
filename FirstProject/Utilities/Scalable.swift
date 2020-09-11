//
//  Scalable.swift
//  FirstProject
//
//  Created by FirstProject on 14.09.2017.
//  Copyright © 2017 AtillaOzder. All rights reserved.
//

import UIKit

protocol Scalable {
    func scale(angle: CGFloat, canRepeat: Bool)
}

extension Scalable where Self: CallButton {
    func scale(angle: CGFloat, canRepeat: Bool) {
        var options: UIViewAnimationOptions = [.allowUserInteraction]
        var trans: CGAffineTransform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        var delay: TimeInterval = 1.5
        
        if canRepeat {
            options.insert(.repeat)
            options.insert(.autoreverse)
            trans = trans.rotated(by: angle)
            delay = 0
        }
        
        UIView.animate(withDuration: 0.5,
                       delay: delay,
                       options: options,
                       animations: {
                        self.transform = trans
        }) { animationEnded in
            if animationEnded {
                trans = CGAffineTransform.identity
                UIView.animate(withDuration: 0.5,
                               delay: 0,
                               options: options,
                               animations: {
                                self.transform = trans
                }) { ended in
                    if ended {
                        self.scale(angle: angle, canRepeat: canRepeat)
                    }
                }
            }
        }
    }
}
