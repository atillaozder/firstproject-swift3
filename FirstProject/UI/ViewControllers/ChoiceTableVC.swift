//
//  ChoiceTableVC.swift
//  FirstProject
//
//  Created by AtillaOzder on 21.03.2017.
//  Copyright © 2017 AtillaOzder. All rights reserved.
//

import UIKit

final class ChoiceTableVC: UITableViewController, ErrorHandling {
    
    // MARK: - Properties
    
    weak var personDelegate: PersonDelegate?
    fileprivate var currentPerson: Person?
    var personHolder: Person {
        get { return self.currentPerson! }
        set { currentPerson = newValue }
    }
    
    var lastSelection: IndexPath!
    let fields: [String] = ["Kadınlar", "Erkekler", "Kadınlar ve Erkekler"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Tercihim"
    }
}

// MARK: - Table View Data Source

extension ChoiceTableVC {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fields.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let text = cell.textLabel?.text {
            if text == AppDelegate.userDefaults.getChoice() {
                cell.tintColor = CustomColors.watermelon.value
                cell.accessoryType = .checkmark
                lastSelection = indexPath
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
}

// MARK: - Table View Delegate

extension ChoiceTableVC {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard lastSelection != indexPath else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        if (self.lastSelection != nil) {
            self.tableView.cellForRow(at: self.lastSelection)?.accessoryType = .none
        }
        
        if (tableView.cellForRow(at: indexPath)?.textLabel?.text == "Kadınlar") {
            personHolder.choice = "female"
        } else if (tableView.cellForRow(at: indexPath)?.textLabel?.text == "Erkekler") {
            personHolder.choice = "male"
        } else {
            personHolder.choice = "both"
        }
        
        tableView.cellForRow(at: indexPath)?.tintColor = CustomColors.watermelon.value
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        tableView.deselectRow(at: indexPath, animated: true)
        
        _ = NetworkManager.sharedManager.patchRequest(person: personHolder).subscribe(onNext: { result in
            
        }, onError: { error in
            
            if self.lastSelection != indexPath {
                tableView.cellForRow(at: self.lastSelection)?.accessoryType = .checkmark
                tableView.cellForRow(at: indexPath)?.accessoryType = .none
            }
            
            self.handle(error: error)
            
        }, onCompleted: {
            
            self.personDelegate?.didUpdate(currentPerson: self.personHolder, fromVC: self)
            self.lastSelection = indexPath
            
        }, onDisposed: {})
    }
}
