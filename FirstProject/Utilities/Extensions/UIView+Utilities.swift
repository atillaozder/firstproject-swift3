//
//  UIView+Utilities.swift
//  FirstProject
//
//  Created by AtillaOzder on 25.04.2017.
//  Copyright © 2017 AtillaOzder. All rights reserved.
//

import UIKit

extension UIView {
    func addConstraintsWithFormat(_ format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format,
                                                      options: NSLayoutFormatOptions(),
                                                      metrics: nil,
                                                      views: viewsDictionary))
    }
}

extension UIImageView {
    func setRenderingAlwaysTemplate() {
        self.image = self.image?.withRenderingMode(.alwaysTemplate)
    }
}
