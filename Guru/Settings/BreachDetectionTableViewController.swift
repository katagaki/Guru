//
//  BreachDetectionTableViewController.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/07.
//

import SafariServices
import UIKit

class BreachDetectionTableViewController: UITableViewController, SFSafariViewControllerDelegate {
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Localization
        navigationItem.title = NSLocalizedString("BreachDetection", comment: "Views")
        
    }
    
    // MARK: UITableViewController
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 1
        case 2: return 2
        case 3:
            switch defaults.bool(forKey: "Feature.BreachDetection") {
            case true: return 2
            case false: return 0
            }
        default: return 0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 3:
            switch defaults.bool(forKey: "Feature.BreachDetection") {
            case true: return NSLocalizedString("DetectionTypes", comment: "BreachDetection")
            case false: return ""
            }
        default: return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ExplainerCell") as! DetailWithImageCell
            cell.titleLabel.text = NSLocalizedString("BreachDetectionExplainer", comment: "BreachDetection")
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MasterToggleCell")!
            let switchView: UISwitch = UISwitch(frame: CGRect.zero)
            switchView.setOn(defaults.bool(forKey: "Feature.BreachDetection"), animated: false)
            switchView.addTarget(self, action: #selector(setBreachDetection(sender:)), for: .valueChanged)
            cell.textLabel!.text = NSLocalizedString("BreachDetectionToggle", comment: "BreachDetection")
            cell.accessoryView = switchView
            return cell
        case 2:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DisclaimerCell")!
                cell.textLabel!.text = NSLocalizedString("HaveIBeenPwnedTitle", comment: "BreachDetection")
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LearnMoreCell")!
                cell.textLabel!.text = NSLocalizedString("HaveIBeenPwnedLearnMore", comment: "BreachDetection")
                return cell
            default: return UITableViewCell()
            }
        case 3:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "EmailToggleCell")!
                let switchView: UISwitch = UISwitch(frame: CGRect.zero)
                switchView.setOn(defaults.bool(forKey: "Feature.BreachDetection.Email"), animated: false)
                switchView.addTarget(self, action: #selector(setBreachDetectionEmail(sender:)), for: .valueChanged)
                cell.accessoryView = switchView
                cell.textLabel!.text = NSLocalizedString("DetectBreachedEmails", comment: "BreachedDetection")
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "PasswordToggleCell")!
                let switchView: UISwitch = UISwitch(frame: CGRect.zero)
                switchView.setOn(defaults.bool(forKey: "Feature.BreachDetection.Password"), animated: false)
                switchView.addTarget(self, action: #selector(setBreachDetectionPassword(sender:)), for: .valueChanged)
                cell.accessoryView = switchView
                cell.textLabel!.text = NSLocalizedString("DetectBreachedPasswords", comment: "BreachedDetection")
                return cell
            default: return UITableViewCell()
            }
        default: return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 2:
            switch indexPath.row {
            case 1:
                let safariViewController = SFSafariViewController(url: URL(string: "https://haveibeenpwned.com")!)
                safariViewController.delegate = self
                present(safariViewController, animated: true)
            default: break
            }
        default: break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Helper Functions
    
    @objc func setBreachDetection(sender: UISwitch) {
        log("Setting Breach Detection settings.")
        defaults.set(sender.isOn, forKey: "Feature.BreachDetection")
        defaults.set(sender.isOn, forKey: "Feature.BreachDetection.Email")
        defaults.set(sender.isOn, forKey: "Feature.BreachDetection.Password")
        tableView.reloadSections(IndexSet(integer: 3), with: .automatic)
    }
    
    @objc func setBreachDetectionEmail(sender: UISwitch) {
        log("Setting Breach Detection email settings.")
        defaults.set(sender.isOn, forKey: "Feature.BreachDetection.Email")
    }
    
    @objc func setBreachDetectionPassword(sender: UISwitch) {
        log("Setting Breach Detection password settings.")
        defaults.set(sender.isOn, forKey: "Feature.BreachDetection.Password")
    }
    
}
