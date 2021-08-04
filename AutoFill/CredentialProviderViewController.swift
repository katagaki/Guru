//
//  CredentialProviderViewController.swift
//  AutoFill
//
//  Created by 堅書真太郎 on 2021/07/17.
//

import AuthenticationServices
import LocalAuthentication
import UIKit

class CredentialProviderViewController: ASCredentialProviderViewController, UITableViewDataSource, UITableViewDelegate {
    
    let defaults = UserDefaults.standard
    let laContext = LAContext()
    
    var autofillLogs: String = "Guru AutoFill Provider Extension"
    
    var userProfile: UserProfile?
    var logins: [Login] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Localization
        navigationItem.title = NSLocalizedString("Logins", comment: "Views")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        unlock()
        if let userProfile = userProfile {
            logins = userProfile.logins
        }
        tableView.reloadData()
    }
    
    // MARK: Interface Builder
    
    @IBAction func cancel(_ sender: AnyObject?) {
        self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code: ASExtensionError.userCanceled.rawValue))
    }
    
    // MARK: ASCredentialProviderViewController
    
    override func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
        log("prepareCredentialList called.")
        if let userProfile = userProfile {
            logins = userProfile.logins.filter({ login in
                for serviceIdentifier in serviceIdentifiers {
                    if serviceIdentifier.type == .URL, let loginURL = login.loginURL, loginURL.contains(serviceIdentifier.identifier) {
                        return true
                    }
                }
                return false
            })
        }
    }

    /*
     Implement this method if your extension supports showing credentials in the QuickType bar.
     When the user selects a credential from your app, this method will be called with the
     ASPasswordCredentialIdentity your app has previously saved to the ASCredentialIdentityStore.
     Provide the password by completing the extension request with the associated ASPasswordCredential.
     If using the credential would require showing custom UI for authenticating the user, cancel
     the request with error code ASExtensionError.userInteractionRequired.
     */
    override func provideCredentialWithoutUserInteraction(for credentialIdentity: ASPasswordCredentialIdentity) {
        log("provideCredentialWithoutUserInteraction called.")
        if let userProfile = userProfile {
            // credentialIdentity.serviceIdentifier.identifier
            let passwordCredential = ASPasswordCredential(user: "j_appleseed", password: "apple1234")
            self.extensionContext.completeRequest(withSelectedCredential: passwordCredential, completionHandler: nil)
        } else {
            self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code:ASExtensionError.userInteractionRequired.rawValue))
        }
    }

    /*
     Implement this method if provideCredentialWithoutUserInteraction(for:) can fail with
     ASExtensionError.userInteractionRequired. In this case, the system may present your extension's
     UI and call this method. Show appropriate UI for authenticating the user then provide the password
     by completing the extension request with the associated ASPasswordCredential.
     */
    override func prepareInterfaceToProvideCredential(for credentialIdentity: ASPasswordCredentialIdentity) {
        log("prepareInterfaceToProvideCredential called.")
    }
    
    // MARK: UITableViewDataSource, UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logins.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell") as! DetailWithImageCell
        cell.iconView.image = userProfile!.logins[indexPath.row].accountIcon()
        cell.titleLabel.text = userProfile!.logins[indexPath.row].accountName
        cell.subtitleLabel.text = userProfile!.logins[indexPath.row].username
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let passwordCredential = ASPasswordCredential(user: logins[indexPath.row].username ?? "", password: logins[indexPath.row].password ?? "")
        self.extensionContext.completeRequest(withSelectedCredential: passwordCredential, completionHandler: nil)
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
        let dateString = String(Date().timeIntervalSince1970).components(separatedBy: ".")[0]
        autofillLogs = "\(autofillLogs)\n[\(dateString)] AUTOFILL: \(text)"
        print(text)
    }
    
}
