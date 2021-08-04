//
//  LoginsNavigationController.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/04.
//

import UIKit

class LoginsNavigationController: UINavigationController, ContentLockable {
        
    // MARK: Helper Functions
    
    func lockContent(animated: Bool, useAutoUnlock: Bool = false) {
        log("Locking \(self.className)")
        reloadTableViews()
    }
    
    func unlockContent() {
        log("Unlocking \(self.className)")
        for viewController in viewControllers {
            if let loginsTableViewController = viewController as? LoginsTableViewController {
                loginsTableViewController.reloadIndex()
            }
        }
        reloadTableViews()
    }
    
}
