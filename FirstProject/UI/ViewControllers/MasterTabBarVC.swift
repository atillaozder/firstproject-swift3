//
//  MasterTabBarVC.swift
//  FirstProject
//
//  Created by AtillaOzder on 21.03.2017.
//  Copyright © 2017 AtillaOzder. All rights reserved.
//

import UIKit

final class MasterTabBarVC: UITabBarController {
    
    // MARK: - Properties
    
    fileprivate var callVC: CallVC? {
        didSet {
            callVC?.personDelegate = self
        }
    }
    
    fileprivate var settingsTVC: SettingsTableVC? {
        didSet {
            settingsTVC?.personDelegate = self
        }
    }
    
    fileprivate var friendsTVC: FriendsTableVC? {
        didSet {
            friendsTVC?.personDelegate = self
        }
    }
    
    fileprivate var currentPerson: Person? {
        willSet {
            updatePerson()
        }
    }
    
    var personHolder: Person {
        get { return currentPerson! }
        set { currentPerson = newValue }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        setupViews()
        setDelegation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updatePerson()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.registerForPushNotifications()
    }
    
    // MARK: - Helpers
    
    private func setupViews() {
        for index in 0...(viewControllers!.count - 1) {
            getNavigationController(fromIndex: index).navigationBar.titleTextAttributes = [
                NSFontAttributeName: UIFont(name: "ChalkboardSE-Regular", size: 21.0)!
            ]
        }
        
        tabBar.items?.forEach({ (item) -> () in
            item.image = item.selectedImage?.withRenderingMode(.alwaysTemplate)
            item.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
            item.title = nil
        })
        
        self.tabBar.tintColor = UIColor.black
        self.selectedIndex = 1
    }
    
    fileprivate func setDelegation() {
        friendsTVC = getNavigationController(fromIndex: 0).viewControllers.first as? FriendsTableVC
        callVC = getNavigationController(fromIndex: 1).viewControllers.first as? CallVC
        settingsTVC = getNavigationController(fromIndex: 2).viewControllers.first as? SettingsTableVC
    }
    
    fileprivate func updatePerson() {
        callVC?.personHolder = currentPerson!
        settingsTVC?.personHolder = currentPerson!
        friendsTVC?.personHolder = currentPerson!
    }
    
    fileprivate func getNavigationController(fromIndex index: Int) -> UINavigationController {
        return self.viewControllers?[index] as! UINavigationController
    }
    
    fileprivate func isTabBarHidden() -> Bool {
        return self.tabBar.frame.origin.y < self.viewControllers![selectedIndex].view.frame.maxY
    }
}

// MARK: - TabBarController Delegate

extension MasterTabBarVC: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        updatePerson()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return isTabBarHidden()
    }
}

// MARK: - Update Current Person

extension MasterTabBarVC: PersonDelegate {
    func didUpdate(currentPerson person: Person, fromVC viewController: UIViewController) {
        self.personHolder = person
    }
}
