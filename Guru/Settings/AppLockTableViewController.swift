//
//  AppLockTableViewController.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/07.
//

import UIKit
import LocalAuthentication

class AppLockTableViewController: UITableViewController {
        
    var isChangingSettings: Bool = false
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        
        // Localization
        navigationItem.title = NSLocalizedString("AppLock", comment: "Views")
        
    }
    
    // MARK: UITableViewController
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 1
        case 2:
            switch defaults.bool(forKey: "Feature.AppLock") {
            case true: return 5
            case false: return 0
            }
        default: return 0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 2:
            switch defaults.bool(forKey: "Feature.AppLock") {
            case true: return NSLocalizedString("TimeBeforeLocking", comment: "AppLock")
            case false: return ""
            }
        default: return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 2:
            switch defaults.bool(forKey: "Feature.AppLock") {
            case true: return NSLocalizedString("TimeoutExplainer", comment: "AppLock")
            case false: return ""
            }
        default: return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ExplainerCell") as! DetailWithImageCell
            switch laContext.biometryType {
            case .faceID: cell.titleLabel.text = NSLocalizedString("AppLockFaceIDExplainer", comment: "AppLock")
            case .touchID: cell.titleLabel.text = NSLocalizedString("AppLockTouchIDExplainer", comment: "AppLock")
            case .none: cell.titleLabel.text = ""
            default: cell.titleLabel.text = ""
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MasterToggleCell")!
            switch laContext.biometryType {
            case .faceID: cell.textLabel?.text = NSLocalizedString("UseFaceID", comment: "AppLock")
            case .touchID: cell.textLabel?.text = NSLocalizedString("UseTouchID", comment: "AppLock")
            case .none: cell.textLabel?.text = NSLocalizedString("UsePasscode", comment: "AppLock")
            default: cell.textLabel?.text = NSLocalizedString("UseBiometrics", comment: "AppLock")
            }
            switch isChangingSettings {
            case true:
                let activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(style: .medium)
                activityIndicatorView.startAnimating()
                cell.accessoryView = activityIndicatorView
            case false:
                let switchView: UISwitch = UISwitch(frame: CGRect.zero)
                switchView.setOn(defaults.bool(forKey: "Feature.AppLock"), animated: false)
                switchView.isEnabled = false
                switchView.addTarget(self, action: #selector(setAppLock(sender:)), for: .valueChanged)
                cell.accessoryView = switchView
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LockAfterCell")!
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = NSLocalizedString("Timeout0", comment: "AppLock")
                cell.accessoryType = (defaults.integer(forKey: "Feature.AppLock.Timeout") == 0 ? .checkmark : .none)
            case 1:
                cell.textLabel?.text = NSLocalizedString("Timeout1", comment: "AppLock")
                cell.accessoryType = (defaults.integer(forKey: "Feature.AppLock.Timeout") == 1 ? .checkmark : .none)
            case 2:
                cell.textLabel?.text = NSLocalizedString("Timeout3", comment: "AppLock")
                cell.accessoryType = (defaults.integer(forKey: "Feature.AppLock.Timeout") == 3 ? .checkmark : .none)
            case 3:
                cell.textLabel?.text = NSLocalizedString("Timeout5", comment: "AppLock")
                cell.accessoryType = (defaults.integer(forKey: "Feature.AppLock.Timeout") == 5 ? .checkmark : .none)
            case 4:
                cell.textLabel?.text = NSLocalizedString("Timeout10", comment: "AppLock")
                cell.accessoryType = (defaults.integer(forKey: "Feature.AppLock.Timeout") == 10 ? .checkmark : .none)
            default: break
            }
            return cell
        default: return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 2:
            let previousAppLockSetting: Int = defaults.integer(forKey: "Feature.AppLock.Timeout")
            var previousAppLockSettingIndex: Int = -1
            switch previousAppLockSetting {
            case 0: previousAppLockSettingIndex = 0
            case 1: previousAppLockSettingIndex = 1
            case 3: previousAppLockSettingIndex = 2
            case 5: previousAppLockSettingIndex = 3
            case 10: previousAppLockSettingIndex = 4
            default: break
            }
            switch indexPath.row {
            case 0:
                log("Setting App Lock timeout to 0 minutes.")
                defaults.set(0, forKey: "Feature.AppLock.Timeout")
            case 1:
                log("Setting App Lock timeout to 1 minute.")
                defaults.set(1, forKey: "Feature.AppLock.Timeout")
            case 2:
                log("Setting App Lock timeout to 3 minutes.")
                defaults.set(3, forKey: "Feature.AppLock.Timeout")
            case 3:
                log("Setting App Lock timeout to 5 minutes.")
                defaults.set(5, forKey: "Feature.AppLock.Timeout")
            case 4:
                log("Setting App Lock timeout to 10 minutes.")
                defaults.set(10, forKey: "Feature.AppLock.Timeout")
            default: break
            }
            if previousAppLockSettingIndex == -1 {
                tableView.reloadSections(IndexSet(integer: 2), with: .automatic)
            } else {
                tableView.reloadRows(at: [IndexPath(row: previousAppLockSettingIndex, section: 2), indexPath], with: .automatic)
            }
        default: break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Helper Functions
    
    @objc func setAppLock(sender: UISwitch) {
        log("Setting App Lock settings.")
        isChangingSettings = true
        tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
        defaults.set(sender.isOn, forKey: "Feature.AppLock")
        isChangingSettings = false
        tableView.reloadData()
    }
    
}
