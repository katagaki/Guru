//
//  SettingsTableViewController.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/05/23.
//

import SafariServices
import UIKit

class SettingsTableViewController: UITableViewController, SFSafariViewControllerDelegate {
    
    @IBOutlet weak var lockAppButton: UIBarButtonItem!
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Localization
        navigationItem.title = NSLocalizedString("Settings", comment: "Views")
        lockAppButton.title = NSLocalizedString("LockApp", comment: "Settings")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
    }
    
    // MARK: Interface Builder
    
    @IBAction func lockApp(_ sender: Any) {
        if let mainTabBarController = parent?.parent as? MainTabBarController {
            mainTabBarController.lockContent(animated: true, useAutoUnlock: false)
        }
    }
    
    // MARK: UITableViewController
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = userProfile {
            switch section {
            case 0: return 1
            case 1: return 3
            case 2: return 2
            case 3: return 3
            case 4: return 1
            case 5: return 0
            default: return 0
            }
        } else {
            return 0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let _ = userProfile {
            return 5
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1: return NSLocalizedString("General", comment: "Settings")
        case 2: return NSLocalizedString("Security", comment: "Settings")
        case 3: return NSLocalizedString("Help", comment: "Settings")
        case 4: return NSLocalizedString("Acknowledgements", comment: "Settings")
        default: return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserProfileCell") as! ProfileHeaderCell
            let fullName = userProfile?.fullName ?? "User"
            cell.nameLabel.text = (fullName == "" ? "User" : fullName)
            cell.detailLabel.text = NSLocalizedString("Version", comment: "Settings").replacingOccurrences(of: "@$1", with: versionNumber).replacingOccurrences(of: "@$2", with: buildNumber)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingItemCell") as! DetailWithImageCell
            switch indexPath.row {
            case 0:
                cell.iconView.image = UIImage(named: "SE.Profile")
                cell.titleLabel.text = NSLocalizedString("Profile", comment: "Settings")
                return cell
            case 1:
                cell.iconView.image = UIImage(named: "SE.Personalization")
                cell.titleLabel.text = NSLocalizedString("Personalization", comment: "Settings")
//            case 2:
//                cell.iconView.image = UIImage(named: "SE.Cloud")
//                cell.titleLabel.text = NSLocalizedString("iCloudSync", comment: "Settings")
            case 2:
                cell.iconView.image = UIImage(named: "SE.Portability")
                cell.titleLabel.text = NSLocalizedString("ImportExport", comment: "Settings")
            default: break
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingItemCell") as! DetailWithImageCell
            switch indexPath.row {
            case 0:
                cell.iconView.image = UIImage(named: "SE.AppLock")
                cell.titleLabel.text = NSLocalizedString("AppLock", comment: "Settings")
            case 1:
                cell.iconView.image = UIImage(named: "SE.BreachDetection")
                cell.titleLabel.text = NSLocalizedString("BreachDetection", comment: "Settings")
            default: break
            }
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingItemCell") as! DetailWithImageCell
            switch indexPath.row {
            case 0:
                cell.iconView.image = UIImage(named: "SE.Support")
                cell.titleLabel.text = NSLocalizedString("GetSupport", comment: "Settings")
            case 1:
                cell.iconView.image = UIImage(named: "SE.FAQ")
                cell.titleLabel.text = NSLocalizedString("FAQs", comment: "Settings")
            case 2:
                cell.iconView.image = UIImage(named: "SE.Debug")
                cell.titleLabel.text = NSLocalizedString("Debug", comment: "Settings")
            default: break
            }
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingItemCell") as! DetailWithImageCell
            cell.iconView.image = UIImage(named: "SE.Licenses")
            cell.titleLabel.text = NSLocalizedString("ThirdPartyLibraries", comment: "Settings")
            return cell
        default: return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            switch indexPath.row {
            case 0:
                performSegue(withIdentifier: "OpenProfileSettings", sender: tableView.cellForRow(at: indexPath)!)
            case 1:
                featureUnavailableAlert(self)
                //performSegue(withIdentifier: "OpenPersonalizationSettings", sender: tableView.cellForRow(at: indexPath)!)
//            case 2:
//                performSegue(withIdentifier: "ShowiCloudSyncSettings", sender: tableView.cellForRow(at: indexPath)!)
            case 2:
                performSegue(withIdentifier: "ShowPortability", sender: tableView.cellForRow(at: indexPath)!)
            default: break
            }
        case 2:
            switch indexPath.row {
            case 0:
                performSegue(withIdentifier: "ShowAppLockSettings", sender: tableView.cellForRow(at: indexPath)!)
            case 1:
                performSegue(withIdentifier: "ShowBreachDetectionSettings", sender: tableView.cellForRow(at: indexPath)!)
            default: break
            }
        case 3:
            switch indexPath.row {
            case 0:
                let safariViewController = SFSafariViewController(url: URL(string: "https://mypwd.guru/support")!)
                safariViewController.delegate = self
                present(safariViewController, animated: true)
            case 1:
                let safariViewController = SFSafariViewController(url: URL(string: "https://mypwd.guru/faqs")!)
                safariViewController.delegate = self
                present(safariViewController, animated: true)
            case 2:
                performSegue(withIdentifier: "OpenDebug", sender: tableView.cellForRow(at: indexPath)!)
            default: break
            }
        case 4:
            performSegue(withIdentifier: "OpenAcknowledgements", sender: tableView.cellForRow(at: indexPath)!)
        default: break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
