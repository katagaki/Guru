//
//  CredentialProviderViewController.swift
//  AutoFill
//
//  Created by 堅書真太郎 on 2021/07/17.
//

import AuthenticationServices
import LocalAuthentication
import os
import UIKit

class CredentialProviderViewController: ASCredentialProviderViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var cancelButton: StylizedButton!
    
    let defaults = UserDefaults.standard
    let laContext = LAContext()
    
    var autofillLogs: String = "Guru AutoFill Provider Extension"
    
    var userProfile: UserProfile?
    var scopedLogins: [Login] = []
    
    var selectedAccountName: String = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset.bottom = blurView.frame.height
        tableView.verticalScrollIndicatorInsets.bottom = blurView.frame.height
        
        // Localization
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: "General"), for: .normal)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if userProfile == nil {
            unlock()
            if let userProfile = userProfile {
                if selectedAccountName != "" {
                    if let login = userProfile.login(withName: selectedAccountName),
                       let password = login.password {
                        let passwordCredential = ASPasswordCredential(user: login.username ?? "", password: password)
                        self.extensionContext.completeRequest(withSelectedCredential: passwordCredential, completionHandler: nil)
                    }
                } else {
                    tableView.reloadData()
                }
            } else {
                extensionContext.cancelRequest(withError:
                                                NSError(domain: ASExtensionErrorDomain,
                                                        code: ASExtensionError.userCanceled.rawValue))
            }
        } else {
            tableView.reloadData()
            
        }
    }
    
    // MARK: Interface Builder
    
    @IBAction func cancel(_ sender: AnyObject?) {
        extensionContext.cancelRequest(withError:
                                        NSError(domain: ASExtensionErrorDomain,
                                                code: ASExtensionError.userCanceled.rawValue))
    }
    
    // MARK: ASCredentialProviderViewController
    
    override func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
        log("prepareCredentialList called.")
        unlock()
        if let userProfile = userProfile {
            
            // Add scoped logins
            if serviceIdentifiers.count > 0 {
                log("Preparing scoped login list for \(serviceIdentifiers[0].identifier).")
                scopedLogins = userProfile.logins.filter({ login in
                    for serviceIdentifier in serviceIdentifiers {
                        if let loginURL = login.loginURL, (loginURL.contains(serviceIdentifier.identifier) || serviceIdentifier.identifier.contains(loginURL)) {
                            return true
                        }
                    }
                    return false
                })
                log("Number of scoped logins: \(scopedLogins.count).")
            }
            
            // Reload credential store
            var identities: [ASPasswordCredentialIdentity] = []
            
            for login in userProfile.logins {
                if let accountName = login.accountName, let loginURL = login.loginURL, let username = login.username {
                    let url: String = (loginURL.starts(with: "https://") || loginURL.starts(with: "http://") ? loginURL : "https://" + loginURL)
                    let identity: ASPasswordCredentialIdentity = ASPasswordCredentialIdentity(serviceIdentifier: ASCredentialServiceIdentifier(identifier: url, type: .URL), user: username, recordIdentifier: accountName)
                    identities.append(identity)
                }
            }
            
            ASCredentialIdentityStore.shared.replaceCredentialIdentities(with: identities) { bool, error in
                if let error = error {
                    self.log("ASCredentialIdentityStore replace completed with error: \(error.localizedDescription).")
                } else {
                    self.log("ASCredentialIdentityStore replace completed.")
                }
            }
        }
    }
    
    override func provideCredentialWithoutUserInteraction(for credentialIdentity: ASPasswordCredentialIdentity) {
        log("provideCredentialWithoutUserInteraction called.")
        extensionContext.cancelRequest(withError:
                                        NSError(domain: ASExtensionErrorDomain,
                                                code: ASExtensionError.userInteractionRequired.rawValue))
    }
    
    override func prepareInterfaceToProvideCredential(for credentialIdentity: ASPasswordCredentialIdentity) {
        log("prepareInterfaceToProvideCredential called.")
        selectedAccountName = credentialIdentity.recordIdentifier!
    }
    
    // MARK: UITableViewDataSource, UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let userProfile = userProfile {
            if scopedLogins.count == 0 {
                return userProfile.logins.count
            } else {
                switch section {
                case 0: return scopedLogins.count
                case 1: return userProfile.logins.count
                default: return 0
                }
            }
        } else {
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if scopedLogins.count == 0 {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if userProfile == nil {
            return ""
        }
        if scopedLogins.count == 0 {
            return NSLocalizedString("AutoFillLogins", comment: "AutoFill")
        } else {
            switch section {
            case 0: return NSLocalizedString("AutoFillSuggestedLogins", comment: "AutoFill")
            case 1: return NSLocalizedString("AutoFillLogins", comment: "AutoFill")
            default: return ""
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if scopedLogins.count > 0 && indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell") as! DetailWithImageCell
            cell.iconView.image = scopedLogins[indexPath.row].accountIcon()
            cell.titleLabel.text = scopedLogins[indexPath.row].accountName
            cell.subtitleLabel.text = scopedLogins[indexPath.row].username
            return cell
        } else {
            if let userProfile = userProfile {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell") as! DetailWithImageCell
                cell.iconView.image = userProfile.logins[indexPath.row].accountIcon()
                cell.titleLabel.text = userProfile.logins[indexPath.row].accountName
                cell.subtitleLabel.text = userProfile.logins[indexPath.row].username
                return cell
            } else {
                return UITableViewCell()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let passwordCredential = ASPasswordCredential(user: scopedLogins[indexPath.row].username ?? "",
                                                          password: scopedLogins[indexPath.row].password ?? "")
            self.extensionContext.completeRequest(withSelectedCredential: passwordCredential, completionHandler: nil)
        case 1:
            if let userProfile = userProfile {
                let passwordCredential = ASPasswordCredential(user: userProfile.logins[indexPath.row].username ?? "",
                                                              password: userProfile.logins[indexPath.row].password ?? "")
                self.extensionContext.completeRequest(withSelectedCredential: passwordCredential, completionHandler: nil)
            }
        default: break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Helper Functions
    
    func unlock() {
        if laContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
            if laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                log("Unlocking with iOS authentication method now!")
                userProfile = UserProfile()
                if let userProfile = userProfile {
                    userProfile.setBiometryType(biometryType: laContext.biometryType)
                    userProfile.setSynchronizable(synchronizable: defaults.bool(forKey: "Feature.iCloudSync"))
                    userProfile.prepareKeychains()
                    if userProfile.open() {
                        log("Successful authentication, user profile opened.")
                    } else {
                        log("Authentication failed, no user profile opened.")
                    }
                }
            } else {
                log("Unable to evaluate biometric policy!")
            }
        } else {
            log("No passcode set!")
        }
    }
    
    func log(_ text: String) {
        os_log("%s", log: .default, type: .info, text)
    }
    
}
