//
//  UIFont+CustomFonts.swift
//  FirstProject
//
//  Created by FirstProject on 31.08.2017.
//  Copyright © 2017 AtillaOzder. All rights reserved.
//

import UIKit

enum CustomFont: String {
    case normal = "HelveticaNeue"
    case bold = "HelveticaNeue-Bold"
    case medium = "HelveticaNeue-Medium "
    case italic = "HelveticaNeue-Italic"
    case light = "HelveticaNeue-Light"
    case ultraLight = "HelveticaNeue-UltraLight"
    case thin = "HelveticaNeue-Thin"
}

extension UIFont {
    class func preferredCustomFont(withSize size: CGFloat, customFont: CustomFont) -> UIFont {
        let systemFontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyle.body)
        let customFontDescriptor = UIFontDescriptor(fontAttributes: [
            UIFontDescriptorFamilyAttribute: customFont.rawValue,
            UIFontDescriptorSizeAttribute: systemFontDescriptor.pointSize
            ])
        
        return UIFont(descriptor: customFontDescriptor, size: size)
    }
}
