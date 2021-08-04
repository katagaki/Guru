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
        case 2: return 4
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
        case 2: return NSLocalizedString("CategoryExplainer", comment: "Personalization")
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
            switchView.setOn(true, animated: false)
            cell.accessoryView = switchView
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell")!
            switch indexPath.row {
            case 0: cell.textLabel?.text = NSLocalizedString("PersonalInformation", comment: "Personalization")
            case 1: cell.textLabel?.text = NSLocalizedString("InterestsTopics", comment: "Personalization")
            case 2: cell.textLabel?.text = NSLocalizedString("ExistingPasswords", comment: "Personalization")
            case 3: cell.textLabel?.text = NSLocalizedString("AutomaticallyLearnedKnowledge", comment: "Personalization")
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
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Helper Functions
    
    func updateSwitchAtIndexPath(_ value: Bool, animated: Bool, indexPath: IndexPath) {
        let cell: UITableViewCell = tableView.cellForRow(at: indexPath)!
        let switchView: UISwitch = cell.accessoryView as! UISwitch
        switchView.setOn(value, animated: animated)
    }
    
}
