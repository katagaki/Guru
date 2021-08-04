//
//  AlertsNavigationController.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/07.
//

import Foundation
import UIKit

class AlertsNavigationController: UINavigationController, ContentLockable {
        
    // MARK: Helper Functions
    
    func lockContent(animated: Bool, useAutoUnlock: Bool = false) {
        log("Locking \(self.className)")
        reloadTableViews()
    }
    
    func unlockContent() {
        log("Unlocking \(self.className)")
        reloadTableViews()
    }
    
}
