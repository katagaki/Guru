//
//  LoginDetailTableViewController.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/05/28.
//

import SafariServices
import SwiftOTP
import UIKit

class LoginDetailTableViewController: UITableViewController, SFSafariViewControllerDelegate, ReceivesQRCodeResult, HandlesCellButton, HandlesTextField {
    
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var accountIconView: RoundedImageView!
    @IBOutlet weak var editToggleButton: UIBarButtonItem!
    
    var floatingCopiedView: UIVisualEffectView = UIVisualEffectView()
    let floatingCopiedLabel: UILabel = singleLinedLabel(withText: NSLocalizedString("Copied", comment: "General"))
    
    weak var reloadsUserProfileData: ReloadsUserProfileData? = nil
    
    var login: Login?
    var timer: Timer?
    var time: Int = 0
    var otp: TOTP?
    var isLoginBreached: Bool?
    
    var offset: Int = 0
    
    var isBreachCheckDone: Bool = false
    var isEditingLogin: Bool = false
    var willReloadTextInputFields: Bool = false
    var currentViewTag: Int = 0
        
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notifications.addObserver(self, selector: #selector(deregisterTimer), name: UIScene.didEnterBackgroundNotification, object: nil)
        if userProfile != nil, login != nil {
            accountNameLabel.text = login!.accountName
            accountIconView.image = login!.accountIcon()
            if let login = login, login.totpSecret != "" {
                initializeOTP()
            }
        }
        
        // Configure floating copied view
        floatingCopiedView = floatingView(views: [floatingCopiedLabel], arrangeAs: .Vertical, margins: 10)
        center(view: floatingCopiedView, in: navigationController!.view)
        
        offset = ((login?.username ?? "").isValidEmail() ? 0 : 1)
        
        // Localization
        editToggleButton.title = NSLocalizedString("Edit", comment: "General")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isBreachCheckDone {
            if let login = login, let username = login.username, username.isValidEmail() {
                DispatchQueue.global(qos: .background).async {
                    checkBreaches(email: username) { [weak self] breached, hasError in
                        if !hasError {
                            if let breached = breached {
                                self?.isLoginBreached = breached.count > 0
                            } else {
                                self?.isLoginBreached = false
                            }
                        } else {
                            log("An error occurred while checking for breaches from LoginDetailTableViewController.")
                            self?.isLoginBreached = false
                        }
                        self?.isBreachCheckDone = true
                        DispatchQueue.main.async {
                            self?.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                        }
                    }
                }
            }
        }
        registerTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        deregisterTimer()
        super.viewWillDisappear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination
        switch segue.identifier {
        case "ShowQRCodeScanner":
            if let otpScannerViewController = destinationViewController as? OTPScannerViewController {
                otpScannerViewController.qrCodeResultReceiver = self
            }
        default: break
        }
    }
    
    // MARK: Interface Builder
    
    @IBAction func toggleEditing(_ sender: Any) {

        if isEditingLogin {
            if let loginURLCell = tableView.cellForRow(at: IndexPath(row: 0, section: 1 - offset)) as? TextInputCell {
                login!.loginURL = loginURLCell.textField.text ?? ""
                userProfile!.setLoginProperty(forAccount: login!.accountName!, loginURL: loginURLCell.textField.text ?? "")
            }
            if let resetURLCell = tableView.cellForRow(at: IndexPath(row: 1, section: 1 - offset)) as? TextInputCell {
                login!.passwordResetURL = resetURLCell.textField.text ?? ""
                userProfile!.setLoginProperty(forAccount: login!.accountName!, passwordResetURL: resetURLCell.textField.text ?? "")
            }
            if let usernameCell = tableView.cellForRow(at: IndexPath(row: 0, section: 2 - offset)) as? TextInputCell {
                login!.username = usernameCell.textField.text ?? ""
                userProfile!.setLoginProperty(forAccount: login!.accountName!, username: usernameCell.textField.text ?? "")
            }
            if let passwordCell = tableView.cellForRow(at: IndexPath(row: 1, section: 2 - offset)) as? TextInputCell {
                login!.password = passwordCell.textField.text ?? ""
                userProfile!.setLoginProperty(forAccount: login!.accountName!, password: passwordCell.textField.text ?? "")
            }
        }
        isEditingLogin = !isEditingLogin
        editToggleButton.title = (isEditingLogin ? NSLocalizedString("Done", comment: "General") : NSLocalizedString("Edit", comment: "General"))
        willReloadTextInputFields = true
        tableView.reloadSections(IndexSet(integersIn: 0...(3 - offset)), with: .automatic)
        willReloadTextInputFields = false
    }
    
    @IBAction func editAccountName(_ sender: Any) {
        if let userProfile = userProfile, let login = login, let accountName = login.accountName {
            showInputAlert(title: NSLocalizedString("AccountName", comment: "Logins"),
                           message: "", textType: .unspecified, keyboardType: .asciiCapable, capitalizationType: .words, placeholder: NSLocalizedString("AccountName", comment: "Logins"), defaultText: accountName, self) { newName in
                if let newName = newName {
                    userProfile.setLoginProperty(forAccount: accountName, accountName: newName)
                    self.login = userProfile.login(withName: newName)
                    self.tableView.reloadData()
                    self.accountNameLabel.text = newName
                }
            }
        }
    }
    
    // MARK: UITableViewController
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = userProfile, let login = login {
            if isEditingLogin {
                switch section {
                case 1 - offset: return 2
                case 2 - offset: return 2
                case 3 - offset: return login.totpSecret == nil ? 1 : 2
                default: return 0
                }
            } else {
                switch section {
                case 0 - offset:
                    if let username = login.username {
                        switch username.isValidEmail() {
                        case true: return 1
                        case false: return 0
                        }
                    } else {
                        return 0
                    }
                case 1 - offset: return 2
                case 2 - offset: return login.username == nil ? 1 : 2
                case 3 - offset: return 1
                default: return 0
                }
            }
        } else {
            return 0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let _ = userProfile, let _ = login {
            if (login?.username ?? "").isValidEmail() {
                return 4
            } else {
                return 3
            }
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1 - offset: return (isEditingLogin ? NSLocalizedString("ServiceURLs", comment: "Logins") : "")
        case 2 - offset: return NSLocalizedString("Credentials", comment: "Logins")
        case 3 - offset: return NSLocalizedString("OneTimePassword", comment: "Logins")
        default: return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0 - offset:
            if let isLoginBreached = isLoginBreached {
                switch isLoginBreached {
                case true:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "AlertCell")!
                    cell.textLabel?.text = NSLocalizedString("AccountAdvisoryTitle", comment: "Logins")
                    cell.detailTextLabel?.text = NSLocalizedString("AccountAdvisoryText", comment: "Logins")
                    return cell
                case false:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "NoBreachDetectedCell")!
                    cell.textLabel?.text = NSLocalizedString("AccountSafeTitle", comment: "Logins")
                    cell.detailTextLabel?.text = NSLocalizedString("AccountSafeText", comment: "Logins")
                    return cell
                }
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CheckingCell") as! ActivityCell
                cell.activityIndicator.startAnimating()
                cell.titleLabel.text = NSLocalizedString("Detecting", comment: "Alerts")
                return cell
            }
        case 1 - offset:
            switch indexPath.row {
            case 0:
                if isEditingLogin {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "LoginPageTextFieldCell") as! TextInputCell
                    cell.titleLabel.text = NSLocalizedString("LoginURL", comment: "Logins")
                    cell.textField.placeholder = NSLocalizedString("LoginURL", comment: "Logins") + NSLocalizedString("Optional", comment: "Logins")
                    if willReloadTextInputFields { cell.textField.text = login?.loginURL }
                    cell.textFieldHandler = self
                    return cell
                } else {
                    if let login = login, let loginURL = login.loginURL, loginURL != "" {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "PWAccountOpenPageCell")!
                        cell.textLabel?.text = NSLocalizedString("OpenLoginPage", comment: "Logins")
                        return cell
                    } else {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "PWAccountSetUpLoginPageCell")!
                        cell.textLabel?.text = NSLocalizedString("SetUpLoginPage", comment: "Logins")
                        return cell
                    }
                }
            case 1:
                if isEditingLogin {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ResetPageTextFieldCell") as! TextInputCell
                    cell.titleLabel.text = NSLocalizedString("PasswordResetURL", comment: "Logins")
                    cell.textField.placeholder = NSLocalizedString("PasswordResetURL", comment: "Logins") + NSLocalizedString("Optional", comment: "Logins")
                    if willReloadTextInputFields { cell.textField.text = login?.passwordResetURL }
                    cell.textFieldHandler = self
                    return cell
                } else {
                    if let login = login, let passwordResetURL = login.passwordResetURL, passwordResetURL != "" {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "PWAccountOpenPageCell")!
                        cell.textLabel?.text = NSLocalizedString("OpenResetPage", comment: "Logins")
                        return cell
                    } else {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "PWAccountSetUpPRPageCell")!
                        cell.textLabel?.text = NSLocalizedString("SetUpResetPage", comment: "Logins")
                        return cell
                    }
                }
            default: return UITableViewCell()
            }
        case 2 - offset:
            if isEditingLogin {
                switch indexPath.row {
                case 0:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "UsernameTextFieldCell") as! TextInputCell
                    cell.titleLabel.text = NSLocalizedString("Username", comment: "Logins")
                    cell.textField.placeholder = NSLocalizedString("Username", comment: "Logins") + NSLocalizedString("Optional", comment: "Logins")
                    if willReloadTextInputFields { cell.textField.text = login!.username }
                    cell.textFieldHandler = self
                    return cell
                case 1:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "PasswordTextFieldCell") as! TextInputCell
                    cell.titleLabel.text = NSLocalizedString("Password", comment: "Logins")
                    cell.textField.placeholder = NSLocalizedString("Password", comment: "Logins")
                    if willReloadTextInputFields { cell.textField.text = login!.password }
                    cell.textField.font = UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: UIFont(name: "Menlo", size: 16.0)!)
                    cell.textFieldHandler = self
                    return cell
                default: return UITableViewCell()
                }
            } else {
                if let login = login, let username = login.username {
                    switch indexPath.row {
                    case 0:
                        let cell = tableView.dequeueReusableCell(withIdentifier: "UsernameCell") as! DetailWithCopyCell
                        cell.titleLabel.text = NSLocalizedString("Username", comment: "Logins")
                        cell.contentLabel.text = username
                        cell.buttonHandler = self
                        return cell
                    case 1:
                        let cell = tableView.dequeueReusableCell(withIdentifier: "PasswordCell") as! DetailWithCopyCell
                        cell.titleLabel.text = NSLocalizedString("Password", comment: "Logins")
                        cell.contentLabel.text = login.password
                        cell.contentLabel.font = UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: UIFont(name: "Menlo", size: 16.0)!)
                        cell.buttonHandler = self
                        return cell
                    default: return UITableViewCell()
                    }
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "PasswordCell") as! DetailWithCopyCell
                    cell.titleLabel.text = "Password"
                    cell.contentLabel.text = login!.password
                    cell.contentLabel.font = UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: UIFont(name: "Menlo", size: 16.0)!)
                    cell.buttonHandler = self
                    return cell
                }
            }
        case 3 - offset:
            switch indexPath.row {
            case 0:
                if let otp = otp {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "PWAccountOTPCell") as! OTPCell
                    var otpString: String = otp.generate(time: Date()) ?? ""
                    otpString.insert(" ", at: otpString.index(otpString.startIndex, offsetBy: 3))
                    cell.otpLabel.text = otpString
                    cell.setProgress(time: time)
                    cell.buttonHandler = self
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "PWAccountSetUp2FACell")!
                    cell.textLabel?.text = NSLocalizedString("SetUp2FA", comment: "Logins")
                    return cell
                }
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "Disable2FACell")!
                cell.textLabel?.text = NSLocalizedString("Delete2FA", comment: "Logins")
                return cell
            default: return UITableViewCell()
            }
        default: return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1 - offset:
            if !isEditingLogin {
                switch indexPath.row {
                case 0:
                    if let login = login, let loginURL = login.loginURL, loginURL != "" {
                        var url = loginURL
                        if !url.starts(with: ("https://")) {
                            url = "https://\(url)"
                        }
                        if let url = URL(string: url) {
                            let safariViewController = SFSafariViewController(url: url)
                            safariViewController.delegate = self
                            present(safariViewController, animated: true)
                        }
                    } else {
                        showInputAlert(title: "Enter Login URL", message: "Set up the login page for this account.", textType: .URL, keyboardType: .URL, capitalizationType: .none, placeholder: "Login URL", defaultText: "", self) { result in
                            if result != nil && result != "" {
                                userProfile?.setLoginProperty(forAccount: self.login!.accountName!, loginURL: result!)
                                self.tableView.reloadData()
                            }
                        }
                    }
                case 1:
                    if let login = login, let passwordResetURL = login.passwordResetURL, passwordResetURL != "" {
                        var url = passwordResetURL
                        if !url.starts(with: ("https://")) {
                            url = "https://\(url)"
                        }
                        if let url = URL(string: url) {
                            let safariViewController = SFSafariViewController(url: url)
                            safariViewController.delegate = self
                            present(safariViewController, animated: true)
                        }
                    } else {
                        showInputAlert(title: "Enter Password Reset URL", message: "Set up the password reset page for this account.", textType: .URL, keyboardType: .URL, capitalizationType: .none, placeholder: "Login URL", defaultText: "", self) { result in
                            if result != nil && result != "" {
                                userProfile?.setLoginProperty(forAccount: self.login!.accountName!, passwordResetURL: result!)
                                self.tableView.reloadData()
                            }
                        }
                    }
                default: break
                }
            }
        case 3 - offset:
            if isEditingLogin {
                switch indexPath.row {
                case 1:
                    let disableOTPAlert = UIAlertController(title: NSLocalizedString("ConfirmDisableOTPTitle", comment: "OTP"), message: NSLocalizedString("ConfirmDisableOTPText", comment: "OTP"), preferredStyle: .alert)
                    disableOTPAlert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "General"), style: .default, handler: { _ in
                        userProfile!.setLoginProperty(forAccount: self.login!.accountName!, totpSecret: "")
                        self.otp = nil
                        self.deregisterTimer()
                        tableView.reloadSections(IndexSet(integer: 2), with: .automatic)
                    }))
                    disableOTPAlert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: "General"), style: .cancel, handler: nil))
                    present(disableOTPAlert, animated: true, completion: nil)
                default: break
                }
            }
        default: break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Timer
    
    func registerTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateOTP), userInfo: nil, repeats: true)
    }
    
    @objc func deregisterTimer() {
        timer?.invalidate()
    }
    
    // MARK: ReceivesQRCodeResult
    
    func receiveQRCode(result value: String) {
        if let login = login {
            if let data = base32DecodeToData(value) {
                userProfile!.setLoginProperty(forAccount: login.accountName!, totpSecret: value)
                otp = TOTP(secret: data, digits: 6, timeInterval: 30, algorithm: .sha1)
                registerTimer()
                time = 30 - (Calendar.current.component(.second, from: Date()) % 30)
                tableView.reloadData()
            } else {
                let invalidOTPAlert = UIAlertController(title: NSLocalizedString("InvalidOTPTitle", comment: "OTP"), message: NSLocalizedString("InvalidOTPText", comment: "OTP"), preferredStyle: .alert)
                invalidOTPAlert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "General"), style: .cancel))
                present(invalidOTPAlert, animated: true)
            }
        }
    }
    
    // MARK: HandlesCellButton
    
    func handleCellButton() {
        UIView.animate(withDuration: 0.25, delay: 0.0, options: []) {
            self.floatingCopiedView.layer.opacity = 1.0
        } completion: { _ in
            UIView.animate(withDuration: 0.25, delay: 0.5, options: []) {
                self.floatingCopiedView.layer.opacity = 0.0
            } completion: { _ in }
        }
    }
    
    // MARK: HandlesCellTextField
    
    func handleTextField() {
        log("Handling text field should return with tag \(currentViewTag).")
        if let view = view.viewWithTag(currentViewTag + 100) {
            currentViewTag += 100
            view.becomeFirstResponder()
        } else {
            view.endEditing(false)
        }
    }
    
    func handleTextFieldBeginEditing(_ sender: UITextField) {
        log("Text field with tag \(currentViewTag) started editing.")
        currentViewTag = sender.tag
    }
    
    // MARK: Helper Functions
    
    func initializeOTP() {
        if let login = login, let totpSecret = login.totpSecret, let data = base32DecodeToData(totpSecret) {
            otp = TOTP(secret: data, digits: 6, timeInterval: 30, algorithm: .sha1)
            updateOTP()
            registerTimer()
        }
    }
    
    @objc func updateOTP() {
        offset = ((login?.username ?? "").isValidEmail() ? 0 : 1)
        
        time = 30 - (Calendar.current.component(.second, from: Date()) % 30)
        
        if userProfile != nil {
            tableView.reloadRows(at: [IndexPath(row: 0, section: 3 - offset)], with: .none)
        } else {
            otp = nil
        }
    }
    
}
