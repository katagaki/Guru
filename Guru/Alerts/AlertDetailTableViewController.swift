//
//  AlertDetailTableViewController.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/22.
//

import UIKit

class AlertDetailTableViewController: UITableViewController {
    
    public var emailAddressToSearch: String = ""
    public var passwordToSearch: String = ""
    
    var loginsAffected: [String] = []
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let userProfile = userProfile {
            if emailAddressToSearch != "" {
                loginsAffected = userProfile.logins.filter({ login in
                    return (login.username ?? "").lowercased() == emailAddressToSearch.lowercased()
                }).map({ login in
                    return login.accountName!
                })
            } else if passwordToSearch != "" {
                loginsAffected = userProfile.logins.filter({ login in
                    return (login.password ?? "") == passwordToSearch
                }).map({ login in
                    return login.accountName!
                })
            }
        }
        
        // Localization
        navigationItem.title = NSLocalizedString("BreachedInformation", comment: "Views")
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPath(for: sender as! UITableViewCell),
           let accountTableViewController = segue.destination as? LoginDetailTableViewController {
            switch segue.identifier {
            case "ShowLoginDetail":
                if let userProfile = userProfile, let login = userProfile.login(withName: loginsAffected[indexPath.row]) {
                    accountTableViewController.login = login
                }
            default: break
            }
        }
    }
    
    // MARK: UITableViewController
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return loginsAffected.count
        default: return 0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1: return NSLocalizedString("AffectedLogins", comment: "Alerts")
        default: return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ExplainerCell") as! DetailWithImageCell
            if emailAddressToSearch != "" {
                cell.titleLabel.text = NSLocalizedString("BreachExplainerEmail", comment: "Alerts").replacingOccurrences(of: "@$", with: emailAddressToSearch)
            } else if passwordToSearch != "" {
                cell.titleLabel.text = NSLocalizedString("BreachExplainerPassword", comment: "Alerts").replacingOccurrences(of: "@$", with: passwordToSearch)
            } else {
                cell.titleLabel.text = NSLocalizedString("BreachExplainer", comment: "Alerts")
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell") as! DetailWithImageCell
            cell.titleLabel.text = loginsAffected[indexPath.row]
            if let userProfile = userProfile, let login = userProfile.login(withName: loginsAffected[indexPath.row]) {
                cell.iconView.image = login.accountIcon() ?? UIImage()
            }
            return cell
        default: return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
