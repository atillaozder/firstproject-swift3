//
//  AppDelegate.swift
//  FirstProject
//
//  Created by AtillaOzder on 21.03.2017.
//  Copyright © 2017 AtillaOzder. All rights reserved.
//

import UIKit
import AVFoundation
import UserNotifications
import PushKit
import FBSDKCoreKit
import KeychainAccess
import FBSDKLoginKit
import RxSwift
import RxCocoa

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    static let keychain = Keychain(service: "com.atillaozder.FirstProject")
    static let loginManager = FBSDKLoginManager()
    static let userDefaults = UserDefaults.standard
    static let disposeBag = DisposeBag()
    static var isStatusBarHidden: Bool = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setupConfigurations()
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }
    
    // MARK: - Helpers
    
    fileprivate func setupConfigurations() {
        UINavigationBar.appearance().barTintColor = CustomColors.bar.value
        UITabBar.appearance().barTintColor = CustomColors.bar.value
        
//        // Label Fonts
//        UILabel.appearance(whenContainedInInstancesOf: [SettingsTableVC.self]).font = UIFont.preferredCustomFont(withSize: 17.0, customFont: .normal)
//        UILabel.appearance(whenContainedInInstancesOf: [ChoiceTableVC.self]).font = UIFont.preferredCustomFont(withSize: 17.0, customFont: .normal)
//        UILabel.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self]).font = UIFont.preferredCustomFont(withSize: 16.0, customFont: .bold)
//        UILabel.appearance(whenContainedInInstancesOf: [UIButton.self]).font = UIFont.preferredCustomFont(withSize: 17.0, customFont: .bold)
//        
//        // Text Fields Fonts
//        
//        UITextField.appearance().font = UIFont.preferredCustomFont(withSize: 15.0, customFont: .normal)
//        
//        // Back Button Fonts
//        
//        UIBarButtonItem.appearance().setTitleTextAttributes([
//            NSFontAttributeName:  UIFont.preferredCustomFont(withSize: 17.0, customFont: .normal)],
//                                                            for: .normal)
//        
//        
//        // Navigation Bar Configurations
//        
//        UINavigationBar.appearance().titleTextAttributes = [
//            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 17.0),
//            NSForegroundColorAttributeName: UIColor.black
//        ]
    }
    
    // MARK: - Register Push Notifications
    
    func registerForPushNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        
        notificationCenter.requestAuthorization(options: [.badge, .alert, .sound], completionHandler: { (granted, error) in
            if error != nil {
                print("UNNotification authorization error: \(error!.localizedDescription)")
            }
            
            guard granted else { return }
            self.getNotificationSettings()
        })
    }
    
    fileprivate func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            guard settings.authorizationStatus == .authorized else { return }
            UIApplication.shared.registerForRemoteNotifications()
            self.registerForVoipNotifications()
        }
    }
    
    // MARK: - PushKit Voip Registration
    
    fileprivate func registerForVoipNotifications() {
        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: DispatchQueue.main)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [PKPushType.voIP]
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("Device Token: \(tokenString)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APNs registration failed: \(error.localizedDescription)")
    }
    
    // MARK: - Receive Remote Notification in Background
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("did Receive Remote Notification \(userInfo)")
        completionHandler(.newData)
    }
    
    // MARK: - Background Fetch
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    }
}

// MARK: - Notification Settings

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        let badge = response.notification.request.content.badge
        let body = response.notification.request.content.body
        let subtitle = response.notification.request.content.subtitle
        let title = response.notification.request.content.title
        
        print("didReceive UNNotification: userInfo - \(userInfo)\nbadge - \(String(describing: badge))\nbody - \(body)\ntitle - \(title)\nsubtitle - \(subtitle)")
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("willPresent UNNotification: userInfo - \(userInfo)")
        completionHandler([.badge, .alert, .sound])
    }
}

// MARK: - Push Notifications For VoIP

extension AppDelegate: PKPushRegistryDelegate {
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, forType type: PKPushType) {
        guard type == .voIP else { return }
        let data = credentials.token.description.data(using: String.Encoding.ascii, allowLossyConversion: true)
        let tokenString = NSString(data: data!, encoding: String.Encoding.ascii.rawValue)! as String
        print("didUpdatePushCredentials: \(tokenString)")
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenForType type: PKPushType) {
        guard type == .voIP else { return }
        print("didInvalidatePushTokenForType")
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, forType type: PKPushType) {
        guard type == .voIP else { return }
        print("didReceiveIncomingPushWithPayload: \(payload.dictionaryPayload)")
        
        let payloadDict = payload.dictionaryPayload["aps"] as? Dictionary<String, String>
        guard let message = payloadDict?["alert"] else { return }
        print(message.description)
        
        if UIApplication.shared.applicationState == .background || UIApplication.shared.applicationState == .inactive {
            let content = UNMutableNotificationContent()
            content.title = NSString.localizedUserNotificationString(forKey: "PushKit Notification", arguments: nil)
            content.body = NSString.localizedUserNotificationString(forKey: message, arguments: nil)
            content.sound = UNNotificationSound.default()
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.001, repeats: false)
            let request = UNNotificationRequest(identifier: "pushKit", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
                if error != nil {
                    print("Notification Request Error: \(error!.localizedDescription)")
                }
            })
        }
    }
}


