//
//  PersonDelegate.swift
//  FirstProject
//
//  Created by FirstProject on 10.09.2017.
//  Copyright © 2017 AtillaOzder. All rights reserved.
//

import UIKit

protocol PersonDelegate: class {
    func didUpdate(currentPerson person: Person, fromVC viewController: UIViewController)
}
