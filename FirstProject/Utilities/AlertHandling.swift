//
//  AlertHandling.swift
//  FirstProject
//
//  Created by AtillaOzder on 30.03.2017.
//  Copyright © 2017 AtillaOzder. All rights reserved.
//

import UIKit

protocol AlertHandling {
    func showAlert(title: String,
                   message: String,
                   withAction action: UIAlertAction,
                   isDismissable: Bool,
                   completionHandler: ((Bool) -> Void)?)
    
    func showAlert(title: String, message: String, withActions actions: [UIAlertAction]?, cancelTitle: String)
    func showActionSheet(withActions actions: [UIAlertAction])
}

extension AlertHandling where Self: UIViewController {
    func showAlert(title: String,
                   message: String,
                   withAction action: UIAlertAction,
                   isDismissable: Bool,
                   completionHandler: ((Bool) -> Void)?) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(action)
        alertController.preferredAction = action
        
        if isDismissable {
            let cancelAction = UIAlertAction(title: "İptal", style: .default, handler: { (alertAction: UIAlertAction) in
                alertController.dismiss(animated: true, completion: nil)
                completionHandler?(true)
            })
            
            alertController.addAction(cancelAction)
        }
        
        alertController.setPresentationStyle(withView: self.view)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlert(title: String, message: String, withActions actions: [UIAlertAction]?, cancelTitle: String) {}
    func showActionSheet(withActions actions: [UIAlertAction]) {}
}

extension AlertHandling where Self: SettingsTableVC {
    
    func showAlert(title: String, message: String, withActions actions: [UIAlertAction]?, cancelTitle: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel)
        alertController.addAction(cancelAction)
        
        if actions != nil {
            for action in actions! {
                alertController.addAction(action)
            }
        }
        
        alertController.setPresentationStyle(withView: self.view)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showActionSheet(withActions actions: [UIAlertAction]) {
        let alertController = UIAlertController(title: nil, message: "Çıkmak istediğine emin misin?", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "İptal", style: .cancel)
        alertController.addAction(cancelAction)
        
        for action in actions {
            alertController.addAction(action)
        }
        
        alertController.setPresentationStyle(withView: self.view)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension AlertHandling where Self: ChatVC {
    func showActionSheet(withActions actions: [UIAlertAction]) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Vazgeç", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        for action in actions {
            action.setValue(UIColor.black, forKey: "titleTextColor")
            if action.title == "Kamera" {
                action.setValue(#imageLiteral(resourceName: "Camera").withRenderingMode(.alwaysTemplate), forKey: "image")
            } else {
                action.setValue(#imageLiteral(resourceName: "Photos").withRenderingMode(.alwaysTemplate), forKey: "image")
            }
            alertController.addAction(action)
        }
        
        alertController.setPresentationStyle(withView: self.view)
        alertController.preferredAction = nil
        self.present(alertController, animated: true, completion: nil)
    }
}


fileprivate extension UIAlertController {
    func setPresentationStyle(withView view: UIView) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            if self.responds(to: #selector(getter: UIViewController.popoverPresentationController)) {
                self.popoverPresentationController?.sourceView = view
            }
        }
    }
}

