//
//  UIColor+CustomColors.swift
//  FirstProject
//
//  Created by AtillaOzder on 25.04.2017.
//  Copyright © 2017 AtillaOzder. All rights reserved.
//

import Foundation
import UIKit

enum CustomColors {
    case flatRed
    case flatWhite
    case flatGreen
    case flatGray
    case watermelon
    case skyBlue
    case facebook
    case splash
    case call
    case hangUp
    case plusView
    case buyBtn
    case bar
}

extension CustomColors {
    var value: UIColor {
        get {
            switch self {
            case .flatRed:
                return UIColor(hue: 0.02, saturation: 0.74, brightness: 0.91, alpha: 1.0)
            case .flatWhite:
                return UIColor(hue: 0.53, saturation: 0.02, brightness: 0.95, alpha: 1.0)
            case .flatGreen:
                return UIColor(hue: 0.40, saturation: 0.77, brightness: 0.80, alpha: 1.0)
            case .flatGray:
                return UIColor(hue: 0.51, saturation: 0.10, brightness: 0.65, alpha: 1.0)
            case .watermelon:
                return UIColor(hue: 0.99, saturation: 0.53, brightness: 0.94, alpha: 1.0)
            case .skyBlue:
                return UIColor(hue: 0.57, saturation: 0.76, brightness: 0.86, alpha: 1.0)
            case .facebook:
                return UIColor.createColorWithRGB(r: 59, g: 89, b: 152)
            case .plusView:
                return UIColor(hex: "#32d285")
            case .buyBtn:
                return UIColor(hex: "#1f77e9")
            case .bar:
                return UIColor.createColorWithRGB(r: 247, g: 247, b: 247)
            default:
                return UIColor.white
            }
        }
    }
    
    var gradientValue: [CGColor] {
        get {
            switch self {
            case .splash:
                return [UIColor.createColorWithRGB(r: 22, g: 81, b: 183).cgColor, UIColor.createColorWithRGB(r: 251, g: 88, b: 197).cgColor]
            case .call:
                return [UIColor.createColorWithRGB(r: 157, g: 69, b: 252).cgColor, UIColor.createColorWithRGB(r: 251, g: 88, b: 197).cgColor]
            case .hangUp:
                return [UIColor(hex: "#cb2d3e").cgColor, UIColor(hex: "#ef473a").cgColor]
            case .plusView:
                return [UIColor(hex: "#32d285").cgColor, UIColor(hex: "#8effcb").cgColor]
            case .buyBtn:
                return [UIColor(hex: "#185edd").cgColor, UIColor(hex: "#2ba2ff").cgColor]
            default:
                return []
            }
        }
    }
}

extension UIColor {
    static func createColorWithRGB(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
        return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
    }
}
