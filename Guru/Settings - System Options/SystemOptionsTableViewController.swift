//
//  SystemOptionsTableViewController.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/07.
//

import UIKit

class SystemOptionsTableViewController: UITableViewController {
        
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Localization
        navigationItem.title = NSLocalizedString("UnderTheHood", comment: "Views")
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
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1: return NSLocalizedString("InternalPreferences", comment: "UnderTheHood")
        case 2: return NSLocalizedString("Logging", comment: "UnderTheHood")
        default: return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ExplainerCell") as! DetailWithImageCell
            cell.titleLabel.text = NSLocalizedString("UnderTheHoodExplainer", comment: "UnderTheHood")
            return cell
        case 1:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "OnboardingCompletedCell")!
                cell.textLabel!.text = NSLocalizedString("OnboardingCompleted", comment: "UnderTheHood")
                cell.detailTextLabel!.text = (defaults.bool(forKey: "Onboarding.Completed") ? NSLocalizedString("Yes", comment: "General") : NSLocalizedString("No", comment: "General"))
                return cell
            default: return UITableViewCell()
            }
        case 2:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AppLogsCell")!
                cell.textLabel!.text = NSLocalizedString("AppLogs", comment: "UnderTheHood")
                return cell
            default: return UITableViewCell()
            }
        default: return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            switch indexPath.row {
            case 0:
                defaults.set(!defaults.bool(forKey: "Onboarding.Completed"), forKey: "Onboarding.Completed")
                defaults.synchronize()
                tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
            default: break
            }
        default: break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
