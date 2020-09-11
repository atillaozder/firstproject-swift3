//
//  Gradientable.swift
//  FirstProject
//
//  Created by FirstProject on 10.09.2017.
//  Copyright © 2017 AtillaOzder. All rights reserved.
//

import UIKit

protocol Gradientable {
    func setGradientLayer(angleInDegs: Int, colors: [CGColor], hasBorder: Bool)
    func getGradientLayer() -> CAGradientLayer
    func changeGradient(toValue value: [CGColor])
}

extension Gradientable where Self: UIView {
    func setGradientLayer(angleInDegs: Int, colors: [CGColor], hasBorder: Bool) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = colors
        gradient.startPoint = startAndEndPoints(fromAngle: angleInDegs).startPoint
        gradient.endPoint = startAndEndPoints(fromAngle: angleInDegs).endPoint
        
        if layer.cornerRadius > 0 {
            gradient.cornerRadius = layer.cornerRadius
        }
        
        if hasBorder {
            let border = CAShapeLayer()
            border.lineWidth = 5
            border.path = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
            border.strokeColor = UIColor.black.cgColor
            border.fillColor = nil
            self.layer.masksToBounds = true
            gradient.mask = border
        }
        
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func getGradientLayer() -> CAGradientLayer {
        return self.layer.sublayers?.first as! CAGradientLayer
    }
    
    func changeGradient(toValue value: [CGColor]) {
        let animation = CABasicAnimation(keyPath: "colors")
        animation.duration = 0.5
        animation.toValue = value
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        self.getGradientLayer().add(animation, forKey: "colorChange")
    }
    
    private func startAndEndPoints(fromAngle angle: Int) -> (startPoint: CGPoint, endPoint: CGPoint) {
        var startPointX: CGFloat = 0.5
        var startPointY: CGFloat = 1.0
        
        var startPoint:CGPoint
        var endPoint:CGPoint
        
        switch true {
        case angle == 0:
            startPointX = 0.5
            startPointY = 1.0
        case angle == 45:
            startPointX = 0.0
            startPointY = 1.0
        case angle == 90:
            startPointX = 0.0
            startPointY = 0.5
        case angle == 135:
            startPointX = 0.0
            startPointY = 0.0
        case angle == 180:
            startPointX = 0.5
            startPointY = 0.0
        case angle == 225:
            startPointX = 1.0
            startPointY = 0.0
        case angle == 270:
            startPointX = 1.0
            startPointY = 0.5
        case angle == 315:
            startPointX = 1.0
            startPointY = 1.0
        case angle > 315 || angle < 45:
            startPointX = 0.5 - CGFloat(tan(angle.degreesToRads()) * 0.5)
            startPointY = 1.0
        case angle > 45 && angle < 135:
            startPointX = 0.0
            startPointY = 0.5 + CGFloat(tan(90.degreesToRads() - angle.degreesToRads()) * 0.5)
        case angle > 135 && angle < 225:
            startPointX = 0.5 - CGFloat(tan(180.degreesToRads() - angle.degreesToRads()) * 0.5)
            startPointY = 0.0
        case angle > 225 && angle < 359:
            startPointX = 1.0
            startPointY = 0.5 - CGFloat(tan(270.degreesToRads() - angle.degreesToRads()) * 0.5)
        default: break
        }
        
        startPoint = CGPoint(x: startPointX, y: startPointY)
        endPoint = startPoint.opposite()
        return (startPoint, endPoint)
    }
}

fileprivate extension Int {
    func degreesToRads() -> Double {
        return (Double(self) * .pi / 180)
    }
}

fileprivate extension CGPoint {
    func opposite() -> CGPoint {
        var oppositePoint = CGPoint()
        let originXValue = self.x
        let originYValue = self.y
        
        oppositePoint.x = 1.0 - originXValue
        oppositePoint.y = 1.0 - originYValue
        return oppositePoint
    }
}
