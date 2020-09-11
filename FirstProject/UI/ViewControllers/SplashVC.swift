//
//  SplashVC.swift
//  FirstProject
//
//  Created by AtillaOzder on 21.03.2017.
//  Copyright © 2017 AtillaOzder. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import SwiftMessages
import RxSwift
import SafariServices

final class LoginButton: SpringButton, Shadowable, Roundable {}
final class SplashView: UIView, Gradientable {}
final class InfoLabel: SpringLabel, Underlinable {}

final class SplashVC: UIViewController, AlertHandling, ErrorHandling {
    
    // MARK: - Properties

    @IBOutlet weak var logoImgView: UIImageView!
    @IBOutlet weak var loginButton: LoginButton!
    @IBOutlet weak var infoLbl: InfoLabel!
    
    @IBOutlet weak var logoViewTop: NSLayoutConstraint!
    @IBOutlet weak var logoViewBottom: NSLayoutConstraint!
    
    fileprivate var currentPerson: Person?
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let termsRange = NSRange(location: 54, length: 19)
    let privacyRange = NSRange(location: 77, length: 21)
    var constant: CGFloat = 0
    
    override var prefersStatusBarHidden: Bool {
        return AppDelegate.isStatusBarHidden
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (loginButton.alpha == 0) && (infoLbl.alpha == 0) {
            logoImgView.transform = CGAffineTransform.identity.scaledBy(x: 0.001, y: 0.001)
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           animations: { 
                            self.logoImgView.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)
            }){ (animationEnded) in
                if animationEnded {
                    self.controlCurrentPerson()
                }
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        (self.view as! Gradientable).getGradientLayer().frame = self.view.bounds
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMasterTabBarVC" {
            if let tabBarVC = segue.destination as? MasterTabBarVC {
                tabBarVC.personHolder = currentPerson!
            }
        } else if segue.identifier == "toNamePopOverVC" {
            if let popOverVC = segue.destination as? NamePopOverVC {
                popOverVC.personHolder = currentPerson!
            }
        }
    }
    
    // MARK: - View Methods
    
    fileprivate func setupViews() {
        changeStatusBarVisibility(withDuration: 0.0)
        
        constant = 1.5 * (loginButton.frame.size.height + infoLbl.frame.size.height)
        logoImgView.image = logoImgView.image?.withRenderingMode(.alwaysTemplate)
        
        // Background View
        let splashView = self.view as! Gradientable
        splashView.setGradientLayer(angleInDegs: 135, colors: CustomColors.splash.gradientValue, hasBorder: false)
        
        // Labels
        let str = "Facebook ile hiçbir şey paylaşmıyoruz.\nOturum açarak, Hizmet Şartlarımızı ve Gizlilik Politikamızı kabul ediyorsun."
        let attrStr = str.getAttributed(size: 12.0, font: .normal, color: .white)
        let mutableStr = NSMutableAttributedString(attributedString: attrStr)
        infoLbl.underline(mutableStr: mutableStr, onRange: termsRange, color: .white)
        infoLbl.underline(mutableStr: mutableStr, onRange: privacyRange, color: .white)
        infoLbl.attributedText = mutableStr
        
        // Buttons
        loginButton.tintColor = CustomColors.facebook.value
        loginButton.setCornersRounded()
        loginButton.addShadow()
    }
    
    // MARK: Helpers
    
    fileprivate func showLoginButton() {
        AppDelegate.loginManager.logOut()
        changeStatusBarVisibility(withDuration: 0.3)
        
        if constant < logoViewTop.constant {
            logoViewTop.constant -= UIApplication.shared.statusBarFrame.height
            UIView.animate(withDuration: 0.5,
                           animations: {
                            self.logoViewTop.constant -= self.constant
                            self.logoViewBottom.constant += self.constant
                            self.view.layoutIfNeeded()
            })
        }

        loginButton.animate()
        infoLbl.animate()
    }
    
    fileprivate func hideLoginButton() {
        if constant >= logoViewTop.constant {
            UIView.animate(withDuration: 0.3,
                           animations: {
                            self.loginButton.alpha = 0.0
                            self.infoLbl.alpha = 0.0
                            self.logoViewTop.constant += self.constant
                            self.logoViewBottom.constant -= self.constant
                            self.view.layoutIfNeeded()
            })
        }
    }
    
    // MARK: - Control Methods
    
    private func controlCurrentPerson() {
        
        if (FBSDKAccessToken.current() != nil) {
            
            _ = NetworkManager.sharedManager.getRequest().subscribe(onNext: { currentPerson in
                self.currentPerson = currentPerson
                
                if (self.currentPerson!.isActive) {
                    
                    if (self.currentPerson!.isBanned) {
                        
                        let okAction = UIAlertAction(title: "Peki, anladım.", style: .default, handler: { (alertAction) in
                            self.showLoginButton()
                        })
                        
                        let title = "Seni yaramaz..."
                        let message = "Geçtiğimiz günlerde birazcık yaramazlık yapmışsın. Bir süre hesabını dondurduk. Bir daha karşılaşmamak dileğiyle..."
                        self.showAlert(title: title,
                                       message: message,
                                       withAction: okAction,
                                       isDismissable: false,
                                       completionHandler: nil)
                        
                    } else {
                        
                        if (self.currentPerson!.age > 0 && self.currentPerson!.isNameChanged) {
                            self.performSegue(withIdentifier: "toMasterTabBarVC", sender: self)
                        } else {
                            self.performSegue(withIdentifier: "toNamePopOverVC", sender: self)
                        }
                    }
                    
                } else {
                    
                    let yesAction = UIAlertAction(title: "Evet", style: .default, handler: { (alertAction) in
                        
                        let person = Person()
                        person.isOnline = true
                        person.isActive = true
                        
                        _ = NetworkManager.sharedManager.patchRequest(person: person).subscribe(onNext: { result in
                            
                        }, onError: { error in
                            
                            self.handle(error: error)
                            
                        }, onCompleted: {
                            
                            self.currentPerson?.isOnline = person.isOnline
                            self.currentPerson?.isActive = person.isActive
                            self.controlCurrentPerson()
                            
                        }, onDisposed: { })
                    })
                    
                    let title = "Geri geeel!"
                    let message = "Hesabın daha önce dondurulmuş. Tekrar açmak ister misin?"
                    self.showAlert(title: title,
                                   message: message,
                                   withAction: yesAction,
                                   isDismissable: true,
                                   completionHandler: { (cancelled) in
                                    if cancelled {
                                        self.showLoginButton()
                                    }
                    })
                }
                
            }, onError: { error in
                
                self.handle(error: error)
                
            }, onCompleted: {
                
            }, onDisposed: { })
            
        } else {
            
            showLoginButton()
            
        }
    }
    
    private func controlToken() {
        if let expiration = AppDelegate.userDefaults.getDate() {
            let currentDate = Date()
            let expirationDate = expiration as! Date

            if expirationDate <= currentDate { self.handleExpiration() }
            else { controlCurrentPerson() }
            
        } else {
            self.handleExpiration()
        }
    }
    
    // MARK: - Action Methods
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        AppDelegate.loginManager.logIn(withReadPermissions: ["public_profile", "email", "user_birthday"], from: self) { (result, error) -> Void in
            
            let loginResult: FBSDKLoginManagerLoginResult = result!
            
            if error != nil {
                print(error!.localizedDescription)
                return
            } else if (loginResult.isCancelled) {
                return
            }
            
            if loginResult.token != nil {
                self.hideLoginButton()
                self.controlToken()
            }
        }
    }
    
    // MARK: - Handle Errors
    
    func handleExpiration() {
        _ = NetworkManager.sharedManager.tokenRequest().subscribe(onNext: { result in
            
            if let accessToken = result["access_token"].string, let seconds = result["expires_in"].int {
                do {
                    let expirationDate = Date().add(seconds: seconds)
                    AppDelegate.userDefaults.setDate(value: expirationDate)
                    try AppDelegate.keychain.set(accessToken, key: "accessToken")
                    NetworkManager.setHTTPHeaders()
                } catch {
                    print(error.localizedDescription)
                }
            }
            
        }, onError: { error in
            
            print(error.localizedDescription)
            self.handleNetwork()
            
        }, onCompleted: {
            
            self.controlCurrentPerson()
            
        }, onDisposed: { })
    }
    
    func handleNetwork() {
        let messageView = CustomMessages.expireError.messageView
        messageView.configureContent(title: nil,
                                     body: "Bağlantı Hatası!",
                                     iconImage: nil,
                                     iconText: nil,
                                     buttonImage: nil,
                                     buttonTitle: "Yenile") { (action) in
                                        SwiftMessages.hide()
                                        self.controlCurrentPerson()
        }
        
        let config = CustomMessages.expireError.config
        SwiftMessages.show(config: config, view: messageView)
    }
}
