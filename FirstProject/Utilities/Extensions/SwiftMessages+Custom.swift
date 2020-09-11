//
//  SwiftMessages+Custom.swift
//  FirstProject
//
//  Created by FirstProject on 29.08.2017.
//  Copyright © 2017 AtillaOzder. All rights reserved.
//

import SwiftMessages

enum CustomMessages {
    case networkError, expireError
}

extension CustomMessages {
    var config: SwiftMessages.Config {
        get {
            switch self {
            case .networkError:
                var config = getDefaultConfig()
                config.duration = .seconds(seconds: 1)
                return config
            case .expireError:
                var config = getDefaultConfig()
                config.duration = .forever
                return config
            }
        }
    }
    
    var messageView: MessageView {
        get {
            switch self {
            case .networkError:
                let customView = getDefaultView()
                customView.configureContent(title: nil, body: "Bağlantı Hatası!", iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: nil, buttonTapHandler: nil)
                customView.button?.isHidden = true
                customView.bodyLabel?.textAlignment = .center
                return customView
            case .expireError:
                return getDefaultView()
            }
        }
    }
    
    fileprivate func getDefaultConfig() -> SwiftMessages.Config {
        var config = SwiftMessages.defaultConfig
        config.dimMode = .gray(interactive: false)
        config.interactiveHide = false
        return config
    }
    
    fileprivate func getDefaultView() -> MessageView {
        let view = MessageView.viewFromNib(layout: .MessageView)
        view.configureTheme(.error)
        view.configureDropShadow()
        
        view.backgroundColor = .lightGray
        view.bodyLabel?.textColor = .white
        if view.button != nil {
            view.button!.tintColor = .white
            view.button!.setTitleColor(.black, for: .normal)
            view.button!.layer.cornerRadius = view.button!.frame.size.height / 2
            view.button!.clipsToBounds = true
        }
        
        return view
    }
}
