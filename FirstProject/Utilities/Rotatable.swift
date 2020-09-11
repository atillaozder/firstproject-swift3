//
//  Rotatable.swift
//  FirstProject
//
//  Created by FirstProject on 13.09.2017.
//  Copyright © 2017 AtillaOzder. All rights reserved.
//

import UIKit

protocol Rotatable: Scalable {
    func rotate(toDegrees degrees: CGFloat)
    func rotate(toRadians radians: CGFloat)
    func rotateInitialPosition()
}

extension Rotatable {
    fileprivate func degreesToRadians(value: CGFloat) -> CGFloat {
        return .pi * value / 180.0
    }
    
    fileprivate func radiansToDegrees(value: CGFloat) -> CGFloat {
        return value * 180 / .pi
    }
}

extension Rotatable where Self: CallButton {
    func rotate(toDegrees degrees: CGFloat) {
        rotate(toRadians: degreesToRadians(value: degrees))
    }
    
    func rotate(toRadians radians: CGFloat) {
        self.layer.removeAllAnimations()
        self.transform = CGAffineTransform.identity
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: [.curveEaseInOut, .beginFromCurrentState],
                       animations: {
                        self.transform = CGAffineTransform(rotationAngle: radians)
                        self.changeGradient(toValue: CustomColors.hangUp.gradientValue)
        }) { animationEnded in
            self.scale(angle: radians, canRepeat: true)
        }
    }
    
    func rotateInitialPosition() {
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: [.curveEaseInOut, .beginFromCurrentState],
                       animations: {
                        self.transform = CGAffineTransform(rotationAngle: 0)
                        self.changeGradient(toValue: CustomColors.call.gradientValue)
        }) { animationEnded in
            self.scale(angle: 0, canRepeat: false)
        }
    }
}
