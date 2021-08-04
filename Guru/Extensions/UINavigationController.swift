//
//  UINavigationController.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/31.
//

import UIKit

extension UINavigationController {
    
    func reloadTableViews() {
        for viewController in viewControllers {
            if let tableViewController = viewController as? UITableViewController {
                tableViewController.tableView.reloadData()
            }
        }
    }
    
}
