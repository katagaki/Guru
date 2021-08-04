//
//  GenerateNavigationController.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/04.
//

import UIKit

class GenerateNavigationController: UINavigationController {
        
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("Generate", comment: "Views")
    }
    
    // MARK: Helper Functions
    
    func lockContent(animated: Bool) {
        log("Locking \(self.className)")
        reloadTableViews()
    }
    
    func unlockContent() {
        log("Unlocking \(self.className)")
        reloadTableViews()
    }
    
}
