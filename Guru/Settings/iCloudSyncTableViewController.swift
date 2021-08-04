//
//  iCloudSyncTableViewController.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/03.
//

import UIKit

class iCloudSyncTableViewController: UITableViewController {
    
    var isChangingSettings: Bool = false
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Localization
        navigationItem.title = NSLocalizedString("iCloudSync", comment: "Views")
        
    }
    
    // MARK: UITableViewController
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 1
        case 2: return 1
        default: return 0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 2: return NSLocalizedString("DeleteCloudData", comment: "CloudSync")
        default: return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ExplainerCell") as! DetailWithImageCell
            if files.ubiquityIdentityToken != nil {
                cell.titleLabel.text = NSLocalizedString("CloudSyncExplainer", comment: "CloudSync")
            } else {
                cell.titleLabel.text = NSLocalizedString("CloudSyncUnavailableExplainer", comment: "CloudSync")
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MasterToggleCell")!
            cell.textLabel?.text = NSLocalizedString("CloudSync", comment: "CloudSync")
            switch isChangingSettings {
            case true:
                let activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(style: .medium)
                activityIndicatorView.startAnimating()
                cell.accessoryView = activityIndicatorView
            case false:
                let switchView: UISwitch = UISwitch(frame: CGRect.zero)
                if files.ubiquityIdentityToken != nil {
                    switchView.setOn(defaults.bool(forKey: "Feature.iCloudSync"), animated: false)
                    switchView.addTarget(self, action: #selector(setiCloudSync(sender:)), for: .valueChanged)
                } else {
                    switchView.setOn(false, animated: false)
                }
                cell.accessoryView = switchView
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DeleteAllCell")!
            return cell
        default: return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Helper Functions
    
    @objc func setiCloudSync(sender: UISwitch) {
        log("Setting iCloud Sync settings.")
        isChangingSettings = true
        tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
        defaults.set(sender.isOn, forKey: "Feature.iCloudSync")
        if let userProfile = userProfile {
            userProfile.delete()
            userProfile.setSynchronizable(synchronizable: defaults.bool(forKey: "Feature.iCloudSync"))
            userProfile.prepareKeychains()
            userProfile.save()
        }
        isChangingSettings = false
        tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
    }
    
}
