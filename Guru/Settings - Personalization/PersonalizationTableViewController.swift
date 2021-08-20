//
//  PersonalizationTableViewController.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/05/23.
//

import UIKit

class PersonalizationTableViewController: UITableViewController {
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Localization
        navigationItem.title = NSLocalizedString("Personalization", comment: "Views")
        
    }
    
    // MARK: UITableViewController
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 1
        case 2: return (defaults.bool(forKey: "Feature.Personalization") ? 3 : 0)
        case 3: return 1
        default: return 0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 2: return NSLocalizedString("Categories", comment: "Personalization")
        default: return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 2: return (defaults.bool(forKey: "Feature.Personalization") ?  NSLocalizedString("CategoryExplainer", comment: "Personalization") : NSLocalizedString("CategoryOffExplainer", comment: "Personalization"))
        case 3: return NSLocalizedString("KnowledgeExplainer", comment: "Personalization")
        default: return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ExplainerCell") as! DetailWithImageCell
            cell.titleLabel.text = NSLocalizedString("PersonalizationExplainer", comment: "Personalization")
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MasterToggleCell")!
            cell.textLabel?.text = NSLocalizedString("PersonalizePasswords", comment: "Personalization")
            let switchView: UISwitch = UISwitch(frame: CGRect.zero)
            switchView.setOn(defaults.bool(forKey: "Feature.Personalization"), animated: false)
            switchView.addTarget(self, action: #selector(setPersonalization(sender:)), for: .valueChanged)
            cell.accessoryView = switchView
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell")!
            switch indexPath.row {
//            case 0:
//                cell.textLabel?.text = NSLocalizedString("PersonalInformation", comment: "Personalization")
//                cell.accessoryType = (defaults.bool(forKey: "Feature.Personalization.ProfileInfo") ? .checkmark : .none)
            case 0:
                cell.textLabel?.text = NSLocalizedString("InterestsTopics", comment: "Personalization")
                cell.accessoryType = (defaults.bool(forKey: "Feature.Personalization.Interests") ? .checkmark : .none)
            case 1:
                cell.textLabel?.text = NSLocalizedString("ExistingPasswords", comment: "Personalization")
                cell.accessoryType = (defaults.bool(forKey: "Feature.Personalization.Habits") ? .checkmark : .none)
            case 2:
                cell.textLabel?.text = NSLocalizedString("AutomaticallyLearnedKnowledge", comment: "Personalization")
                cell.accessoryType = (defaults.bool(forKey: "Feature.Personalization.Intelligence") ? .checkmark : .none)
            default: break
            }
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ManageCell")!
            cell.textLabel?.text = NSLocalizedString("ManageKnowledge", comment: "Personalization")
            return cell
        default: return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 2:
            let cell = tableView.cellForRow(at: indexPath)!
            switch indexPath.row {
//            case 0: defaults.set(!(cell.accessoryType == .checkmark), forKey: "Feature.Personalization.ProfileInfo")
            case 0: defaults.set(!(cell.accessoryType == .checkmark), forKey: "Feature.Personalization.Interests")
            case 1: defaults.set(!(cell.accessoryType == .checkmark), forKey: "Feature.Personalization.Habits")
            case 2: defaults.set(!(cell.accessoryType == .checkmark), forKey: "Feature.Personalization.Intelligence")
            default: break
            }
            tableView.reloadRows(at: [indexPath], with: .none)
        default: break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Helper Functions
    
    func updateSwitchAtIndexPath(_ value: Bool, animated: Bool, indexPath: IndexPath) {
        let cell: UITableViewCell = tableView.cellForRow(at: indexPath)!
        let switchView: UISwitch = cell.accessoryView as! UISwitch
        switchView.setOn(value, animated: animated)
    }
    
    @objc func setPersonalization(sender: UISwitch) {
        log("Setting Personalization settings.")
        defaults.set(sender.isOn, forKey: "Feature.Personalization")
        defaults.set(false, forKey: "Feature.Personalization.ProfileInfo")
        defaults.set(sender.isOn, forKey: "Feature.Personalization.Interests")
        defaults.set(sender.isOn, forKey: "Feature.Personalization.Habits")
        defaults.set(sender.isOn, forKey: "Feature.Personalization.Intelligence")
        tableView.reloadSections(IndexSet(integer: 2), with: .automatic)
    }
    
}
