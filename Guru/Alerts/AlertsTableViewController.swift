//
//  AlertsTableViewController.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/05/27.
//

import UIKit

class AlertsTableViewController: UITableViewController {
        
    var isFirstBreachCheckDone: Bool = false
    var isCheckingEmailsForBreaches: Bool = false
    var isCheckingPasswordsForBreaches: Bool = false
        
    // MARK: UIViewController
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        // Localization
        navigationItem.title = NSLocalizedString("Alerts", comment: "Views")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        log("\(self.className) has appeared.")
        if !isCheckingEmailsForBreaches && !isCheckingPasswordsForBreaches {
            refreshControl?.endRefreshing()
        }
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "ShowAffectedLogins":
            if let sender = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: sender) {
                switch indexPath.section {
                case 0:
                    if let destination = segue.destination as? AlertDetailTableViewController, let emailPwnage = emailPwnage {
                        destination.emailAddressToSearch = Array(emailPwnage.keys)[indexPath.row]
                    }
                case 1:
                    if let destination = segue.destination as? AlertDetailTableViewController, let passwordPwnage = passwordPwnage {
                        destination.passwordToSearch = passwordPwnage[indexPath.row]
                    }
                default: break
                }
            }
        default: break
        }
    }
    
    // MARK: UITableViewController
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = userProfile {
            if !isFirstBreachCheckDone {
                switch section {
                case 0: return 1
                default: return 0
                }
            } else {
                switch section {
                case 0:
                    if isCheckingEmailsForBreaches {
                        return 1
                    }
                    if let emailPwnage = emailPwnage {
                        if emailPwnage.count == 0 {
                            return 1
                        } else {
                            return emailPwnage.count
                        }
                    } else {
                        return 1
                    }
                case 1:
                    if isCheckingPasswordsForBreaches {
                        return 1
                    }
                    if let passwordPwnage = passwordPwnage {
                        if passwordPwnage.count == 0 {
                            return 1
                        } else {
                            return passwordPwnage.count
                        }
                    } else {
                        return 1
                    }
                case 2: return 2
                default: return 0
                }
            }
        } else {
            return 0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let _ = userProfile {
            return 2
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch isFirstBreachCheckDone {
        case false: return ""
        case true:
            switch section {
            case 0: return NSLocalizedString("BreachedEmails", comment: "Alerts")
            case 1: return NSLocalizedString("BreachedPasswords", comment: "Alerts")
            default: return ""
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            switch isCheckingEmailsForBreaches {
            case true: return NSLocalizedString("EmailCheckingTakesTime", comment: "Alerts")
            case false: return ""
            }
        default: return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch isFirstBreachCheckDone {
        case false:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ExplainerCell") as! DetailWithImageCell
            cell.titleLabel.text = NSLocalizedString("AlertsExplainer", comment: "Alerts")
            return cell
        case true:
            switch indexPath.section {
            case 0:
                if !isFirstBreachCheckDone || isCheckingEmailsForBreaches {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "CheckingCell") as! ActivityCell
                    cell.activityIndicator.startAnimating()
                    cell.titleLabel.text = NSLocalizedString("Detecting", comment: "Alerts")
                    return cell
                } else {
                    if let emailPwnage = emailPwnage {
                        if emailPwnage.count == 0 {
                            let cell = tableView.dequeueReusableCell(withIdentifier: "NoBreachDetectedCell")!
                            cell.textLabel?.text = NSLocalizedString("NoBreachDetected", comment: "Alerts")
                            cell.detailTextLabel?.text = NSLocalizedString("EmailNoAlert", comment: "Alerts")
                            return cell
                        } else {
                            let cell = tableView.dequeueReusableCell(withIdentifier: "BreachItemCell") as! DetailWithImageCell
                            let name: String = Array(emailPwnage.keys)[indexPath.row]
                            let breaches: [Pwnage] = Array(emailPwnage.values)[indexPath.row]
                            let breachNames: [String] = breaches.map { pwnage in
                                return pwnage.Name!
                            }
                            cell.iconView.image = UIImage(named: "Alert.Email")
                            cell.titleLabel.text = name
                            cell.subtitleLabel.text = NSLocalizedString("IncludedIn", comment: "Alerts").replacingOccurrences(of: "@$", with: breachNames[0...(breachNames.count < 3 ? breachNames.count - 1 : 2)].joined(separator: NSLocalizedString("Concatenator", comment: "General")))
                            return cell
                        }
                    } else {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "CouldNotCheckCell")!
                        cell.textLabel!.text = NSLocalizedString("ErrorCheckingBreachesTitle", comment: "Alerts")
                        cell.detailTextLabel!.text = NSLocalizedString("ErrorCheckingBreachesText", comment: "Alerts")
                        return cell
                    }
                }
            case 1:
                if !isFirstBreachCheckDone || isCheckingPasswordsForBreaches {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "CheckingCell") as! ActivityCell
                    cell.activityIndicator.startAnimating()
                    cell.titleLabel.text = NSLocalizedString("Detecting", comment: "Alerts")
                    return cell
                } else {
                    if let passwordPwnage = passwordPwnage {
                        if passwordPwnage.count == 0 {
                            let cell = tableView.dequeueReusableCell(withIdentifier: "NoBreachDetectedCell")!
                            cell.textLabel?.text = NSLocalizedString("NoBreachDetected", comment: "Alerts")
                            cell.detailTextLabel?.text = NSLocalizedString("PasswordNoAlert", comment: "Alerts")
                            return cell
                        } else {
                            let cell = tableView.dequeueReusableCell(withIdentifier: "BreachItemCell") as! DetailWithImageCell
                            let password: String = passwordPwnage[indexPath.row]
                            cell.iconView.image = UIImage(named: "Alert.Password")
                            cell.titleLabel.text = password
                            cell.subtitleLabel.text = ""
                            return cell
                        }
                    } else {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "CouldNotCheckCell")!
                        cell.textLabel!.text = NSLocalizedString("ErrorCheckingBreachesTitle", comment: "Alerts")
                        cell.detailTextLabel!.text = NSLocalizedString("ErrorCheckingBreachesText", comment: "Alerts")
                        return cell
                    }
                }
            default: return UITableViewCell()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Helper Functions
    
    @objc func refresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            self.isFirstBreachCheckDone = true
            self.checkLoginsForBreaches()
        }
    }
    
    @objc func checkLoginsForBreaches() {
        if let userProfile = userProfile, !isCheckingEmailsForBreaches && !isCheckingPasswordsForBreaches {
            log("Checking login emails for breaches on thread...")
            isCheckingEmailsForBreaches = true
            isCheckingPasswordsForBreaches = true
            emailPwnage = nil
            passwordPwnage = nil
            tableView.reloadSections(IndexSet(integersIn: 0...1), with: .automatic)
            DispatchQueue.global(qos: .background).async {
                let emailsToCheck: [String] = userProfile.logins.map { login in
                    if let username = login.username, username.isValidEmail() {
                        return username
                    } else {
                        return ""
                    }
                }.filter { login in
                    return login != ""
                }
                let breachInfo = checkBreaches(emails: emailsToCheck)
                emailPwnage = breachInfo.breaches
                log("Async email breach check complete, reloading UI.")
                DispatchQueue.main.async {
                    self.isCheckingEmailsForBreaches = false
                    if let _ = self.viewIfLoaded?.window {
                        self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                    }
                    if !self.isCheckingPasswordsForBreaches {
                        self.refreshControl?.endRefreshing()
                    }
                }
            }
            log("Checking passwords for breaches on thread...")
            DispatchQueue.global(qos: .background).async {
                let passwordsToCheck: [String] = userProfile.logins.map { login in
                    return login.password ?? ""
                }.filter { login in
                    return login != ""
                }
                let breachInfo = checkBreaches(passwords: passwordsToCheck)
                passwordPwnage = Array(breachInfo.breaches.keys)
                log("Async password breach check complete, reloading UI.")
                DispatchQueue.main.async {
                    self.isCheckingPasswordsForBreaches = false
                    if let _ = self.viewIfLoaded?.window {
                        self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
                    }
                    if !self.isCheckingEmailsForBreaches {
                        self.refreshControl?.endRefreshing()
                    }
                }
            }
        }
    }
    
}
