//
//  ErrorHandling.swift
//  FirstProject
//
//  Created by FirstProject on 4.09.2017.
//  Copyright © 2017 AtillaOzder. All rights reserved.
//

import UIKit
import SwiftMessages
import MBProgressHUD

protocol ErrorHandling {
    func handleExpiration()
    func handleNetwork()
    func handle(error: Error)
}

extension ErrorHandling where Self: UIViewController {
    
    func handleExpiration() {
        let messageView = CustomMessages.expireError.messageView
        messageView.configureContent(title: "",
                                     body: "Oturum süreniz sona erdi. Devam edebilmek için lütfen yenileyin.",
                                     iconImage: nil,
                                     iconText: nil,
                                     buttonImage: nil,
                                     buttonTitle: "Yenile") { (action) in
            
            let refreshIndicator = MBProgressHUD.showAdded(to: self.view, animated: true)
            refreshIndicator.mode = MBProgressHUDMode.indeterminate
            refreshIndicator.detailsLabel.text = "Yenileniyor"
            refreshIndicator.isUserInteractionEnabled = false
            refreshIndicator.removeFromSuperViewOnHide = true
            
            SwiftMessages.hide()
            self.view.isUserInteractionEnabled = false
            
            _ = NetworkManager.sharedManager.tokenRequest().subscribe(onNext: { result in
                
                if let accessToken = result["access_token"].string, let seconds = result["expires_in"].int {
                    do {
                        let expirationTime = Date().add(seconds: seconds)
                        AppDelegate.userDefaults.setDate(value: expirationTime)
                        try AppDelegate.keychain.set(accessToken, key: "accessToken")
                        NetworkManager.setHTTPHeaders()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                
            }, onError: { error in
                
                refreshIndicator.hide(animated: true)
                self.handleNetwork()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    self.setBars(interactionEnabled: false)
                    SwiftMessages.show(config: CustomMessages.expireError.config, view: messageView)
                })
                
            }, onCompleted: {
                
                refreshIndicator.hide(animated: true)
                self.view.isUserInteractionEnabled = true
                self.setBars(interactionEnabled: true)
                
            }, onDisposed: { })
        }
        
        setBars(interactionEnabled: false)
        SwiftMessages.show(config: CustomMessages.expireError.config, view: messageView)
    }
    
    func handleNetwork() {
        setBars(interactionEnabled: false)
        SwiftMessages.show(config: CustomMessages.networkError.config, view: CustomMessages.networkError.messageView)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.setBars(interactionEnabled: true)
        })
    }
    
    func handle(error: Error) {
        let responseError: NSError = error as NSError
        if responseError.code == 401 { self.handleExpiration() }
        else { self.handleNetwork() }
    }
    
    // MARK: - Helper
    
    fileprivate func setBars(interactionEnabled: Bool) {
        if !self.isKind(of: ChoiceTableVC.self) {
            if self.tabBarController != nil {
                if interactionEnabled != self.tabBarController!.tabBar.isUserInteractionEnabled {
                    self.tabBarController!.tabBar.isUserInteractionEnabled = interactionEnabled
                }
            }
        }
        
        if self.navigationController != nil {
            if interactionEnabled != self.navigationController!.navigationBar.isUserInteractionEnabled {
                self.navigationController!.navigationBar.isUserInteractionEnabled = interactionEnabled
            }
        }
    }
}

