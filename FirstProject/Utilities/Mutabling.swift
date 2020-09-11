//
//  Mutabling.swift
//  FirstProject
//
//  Created by FirstProject on 15.09.2017.
//  Copyright © 2017 AtillaOzder. All rights reserved.
//

import UIKit

protocol Mutabling {
    func setMutableAttributed(fromTexts texts: [NSAttributedString])
}

extension Mutabling where Self: UILabel {
    func setMutableAttributed(fromTexts texts: [NSAttributedString]) {
        let mutableStr = NSMutableAttributedString()
        texts.forEach { text in
            mutableStr.append(text)
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 5.0
        paragraphStyle.alignment = .center
        
        mutableStr.addAttributes(
            [NSParagraphStyleAttributeName: paragraphStyle],
            range: NSRange(location: 0, length: mutableStr.length)
        )
        
        self.attributedText = mutableStr
    }
}
