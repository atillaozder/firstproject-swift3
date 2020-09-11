//
//  String+Shortcuts.swift
//  FirstProject
//
//  Created by FirstProject on 15.09.2017.
//  Copyright © 2017 AtillaOzder. All rights reserved.
//

import UIKit

extension String {
    func getAttributed(size: CGFloat, font: CustomFont, color: UIColor) -> NSAttributedString {
        return NSAttributedString(string: self,
                                  attributes: [
                                    NSFontAttributeName: UIFont.preferredCustomFont(withSize: size, customFont: font),
                                    NSForegroundColorAttributeName: color
            ])
    }
}
