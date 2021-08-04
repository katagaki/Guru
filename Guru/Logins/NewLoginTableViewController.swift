//
//  NewLoginTableViewController.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/06/30.
//

import FaviconFinder
import SwiftOTP
import UIKit

class NewLoginTableViewController: UITableViewController, ReceivesQRCodeResult, HandlesCellButton, HandlesTextField {
    
    var keywords: [String: String] = [:]
    var icons: [String] = []
    var websiteIcon: UIImage = UIImage()
    var totpSecret: String = ""
    
    var usesWebsiteIcon: Bool = true
    
    var presetPassword: String = ""
    var isBusy: Bool = false
    var currentViewTag: Int = 0
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var timer: Timer?
    var time: Int = 0
    var otp: TOTP?

    weak var reloadsUserProfileData: ReloadsUserProfileData? = nil
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Load keyword list for automatic icon selection
        if let plistFile = Bundle.main.path(forResource: "Keywords", ofType: "plist"), let dict = NSDictionary(contentsOfFile: plistFile) {
            for (key, value) in dict {
                keywords.updateValue(value as! String, forKey: key as! String)
            }
        }
        
        // Load icons list
        icons.removeAll()
        for i: Int in 1...72 {
            icons.append("AI." + String.init(format: "%03d", i))
        }
        
        // Localization
        navigationItem.title = NSLocalizedString("NewLogin", comment: "Views")
        addButton.title = NSLocalizedString("Add", comment: "General")
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
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
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func add(_ sender: Any) {
        
        let accountName: String = (tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! TextInputCell).textField.text!
        let username: String = (tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! TextInputCell).textField.text!
        let password: String = (tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as! TextInputCell).textField.text!
        let loginURL: String = (tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as! TextInputCell).textField.text!
        let passwordResetURL: String = (tableView.cellForRow(at: IndexPath(row: 1, section: 2)) as! TextInputCell).textField.text!
        
        let login: Login = Login()
        
        if let userProfile = userProfile {
            if accountName == "" {
                let noNameAlert = UIAlertController(title: NSLocalizedString("AccountNameRequiredTitle", comment: "Logins"),
                                                    message: NSLocalizedString("AccountNameRequiredText", comment: "Logins"),
                                                    preferredStyle: .alert)
                noNameAlert.addAction(UIAlertAction(title: NSLocalizedString("TryAgain", comment: "General"),
                                                    style: .cancel,
                                                    handler: nil))
                present(noNameAlert, animated: true, completion: nil)
            } else if userProfile.logins.contains(where: { login in
                return login.accountName == accountName
            }) {
                let alreadyExistsAlert = UIAlertController(title: NSLocalizedString("LoginAlreadyExistsTitle", comment: "Logins"),
                                                           message: NSLocalizedString("LoginAlreadyExistsText", comment: "Logins"),
                                                           preferredStyle: .alert)
                alreadyExistsAlert.addAction(UIAlertAction(title: NSLocalizedString("TryAgain", comment: "General"),
                                                           style: .cancel,
                                                           handler: nil))
                present(alreadyExistsAlert, animated: true, completion: nil)
            } else if password == "" {
                let noPasswordAlert = UIAlertController(title: NSLocalizedString("PasswordRequiredTitle", comment: "Logins"),
                                                        message: NSLocalizedString("PasswordRequiredText", comment: "Logins"),
                                                        preferredStyle: .alert)
                noPasswordAlert.addAction(UIAlertAction(title: NSLocalizedString("TryAgain", comment: "General"),
                                                        style: .cancel,
                                                        handler: nil))
                present(noPasswordAlert, animated: true, completion: nil)
            } else if usesWebsiteIcon && loginURL == "" {
                let noURLAlert = UIAlertController(title: NSLocalizedString("LoginPageRequiredTitle", comment: "Logins"),
                                                   message: NSLocalizedString("LoginPageRequiredText", comment: "Logins"),
                                                   preferredStyle: .alert)
                noURLAlert.addAction(UIAlertAction(title: NSLocalizedString("TryAgain", comment: "General"),
                                                   style: .cancel,
                                                   handler: nil))
                self.present(noURLAlert, animated: true, completion: nil)
            } else {
                
                isBusy = true
                
                login.accountName = accountName
                login.username = username
                login.password = password
                login.totpSecret = totpSecret
                login.loginURL = loginURL
                login.passwordResetURL = passwordResetURL
                
                DispatchQueue.global(qos: .default).sync {
                    let activityIndicator = UIActivityIndicatorView(style: .medium)
                    let activityIndicatorBarButtonItem = UIBarButtonItem(customView: activityIndicator)
                    navigationItem.title = NSLocalizedString("GettingWebsiteIcon", comment: "Logins")
                    navigationItem.rightBarButtonItem = activityIndicatorBarButtonItem
                    view.endEditing(true)
                    tableView.reloadData()
                    activityIndicator.startAnimating()
                }
                
                DispatchQueue.global(qos: .background).async {
                    
                    if self.usesWebsiteIcon {
                        let semaphore = DispatchSemaphore(value: 0)
                        login.setAccountIcon {
                            semaphore.signal()
                        }
                        semaphore.wait()
                    } else {
                        DispatchQueue.main.sync {
                            login.setAccountIcon(newIcon: (self.tableView.cellForRow(at: IndexPath(row: 0, section: 3)) as! IconCarousellCell).selectedIcon)
                        }
                    }
                    userProfile.add(login: login)
                    
                    DispatchQueue.main.async {
                        self.dismiss(animated: true) {
                            self.reloadsUserProfileData?.reloadUserProfileData()
                        }
                    }
                    
                }
                
            }
        }
    }
    
    // MARK: UITableViewController
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 2
        case 2: return 2
        case 3:
            switch usesWebsiteIcon {
            case true:
                return 1
            case false:
                return 2
            }
        case 4: return 1
        default: return 0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1: return NSLocalizedString("Credentials", comment: "Logins")
        case 2: return NSLocalizedString("ServiceURLs", comment: "Logins")
        case 3: return NSLocalizedString("Icon", comment: "Logins")
        case 4: return NSLocalizedString("2FA", comment: "Logins")
        default: return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AccountNameTextFieldCell") as! TextInputCell
            cell.textField.placeholder = NSLocalizedString("AccountName", comment: "Logins")
            cell.textField.isEnabled = !isBusy
            cell.textFieldHandler = self
            return cell
        case 1:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "UsernameTextFieldCell") as! TextInputCell
                cell.textField.placeholder = NSLocalizedString("Username", comment: "Logins") + NSLocalizedString("Optional", comment: "Logins")
                cell.textField.isEnabled = !isBusy
                cell.textFieldHandler = self
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "PasswordTextFieldCell") as! TextInputCell
                cell.textField.placeholder = NSLocalizedString("Password", comment: "Logins")
                cell.textField.font = UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: UIFont(name: "Menlo", size: 16.0)!)
                if presetPassword != "" {
                    cell.textField.text = presetPassword
                    presetPassword = ""
                }
                cell.textField.isEnabled = !isBusy
                cell.textFieldHandler = self
                return cell
            default: return UITableViewCell()
            }
        case 2:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LoginPageTextFieldCell") as! TextInputCell
                cell.textField.placeholder = NSLocalizedString("LoginURL", comment: "Logins") + (usesWebsiteIcon ? "" : NSLocalizedString("Optional", comment: "Logins"))
                cell.textField.isEnabled = !isBusy
                cell.textFieldHandler = self
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ResetPageTextFieldCell") as! TextInputCell
                cell.textField.placeholder = NSLocalizedString("PasswordResetURL", comment: "Logins") + NSLocalizedString("Optional", comment: "Logins")
                cell.textField.isEnabled = !isBusy
                cell.textFieldHandler = self
                return cell
            default: return UITableViewCell()
            }
        case 3:
            switch usesWebsiteIcon {
            case true:
                let cell = tableView.dequeueReusableCell(withIdentifier: "UseFaviconCell")!
                cell.textLabel?.text = NSLocalizedString("UseWebsiteIcon", comment: "Logins")
                cell.accessoryType = .checkmark
                return cell
            case false:
                switch indexPath.row {
                case 0:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "IconCarousellCell") as! IconCarousellCell
                    cell.icons = icons
                    cell.isSelectable = !isBusy
                    return cell
                case 1:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "UseFaviconCell")!
                    cell.textLabel?.text = NSLocalizedString("UseWebsiteIcon", comment: "Logins")
                    cell.accessoryType = .none
                    return cell
                default: return UITableViewCell()
                }
            }
        case 4:
            if totpSecret == "" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SetUp2FACell")!
                cell.textLabel?.text = NSLocalizedString("SetUp2FA", comment: "Logins")
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "OTPCell") as! OTPCell
                if let otp = otp {
                    var otpString: String = otp.generate(time: Date()) ?? ""
                    otpString.insert(" ", at: otpString.index(otpString.startIndex, offsetBy: 3))
                    cell.otpLabel.text = otpString
                    cell.setProgress(time: time)
                    cell.buttonHandler = self
                }
                return cell
            }
        default: return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isBusy {
            switch indexPath.section {
            case 3:
                usesWebsiteIcon = !usesWebsiteIcon
                if let textField = view.viewWithTag(400) as? UITextField {
                    textField.placeholder = NSLocalizedString("LoginURL", comment: "Logins") + (usesWebsiteIcon ? "" : NSLocalizedString("Optional", comment: "Logins"))
                }
                tableView.reloadSections(IndexSet(integer: 3), with: .automatic)
            default: break
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Timer
    
    func registerTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateOTP), userInfo: nil, repeats: true)
    }
    
    func deregisterTimer() {
        timer?.invalidate()
    }
    
    // MARK: ReceivesQRCodeResult
    
    func receiveQRCode(result value: String) {
        if let data = base32DecodeToData(value) {
            totpSecret = value
            otp = TOTP(secret: data, digits: 6, timeInterval: 30, algorithm: .sha1)
            registerTimer()
            time = 30 - (Calendar.current.component(.second, from: Date()) % 30)
            tableView.reloadData()
        } else {
            let invalidOTPAlert = UIAlertController(title: NSLocalizedString("InvalidOTPTitle", comment: "OTP"), message: NSLocalizedString("InvalidOTPText", comment: "OTP"), preferredStyle: .alert)
            invalidOTPAlert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "General"), style: .cancel, handler: { _ in
                self.navigationController?.popViewController(animated: true)
            }))
            present(invalidOTPAlert, animated: true)
        }
    }
    
    // MARK: HandlesCellButton
    
    func handleCellButton() {
        let backgroundView: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        let copiedLabel: UILabel = UILabel()
        copiedLabel.text = NSLocalizedString("Copied", comment: "General")
        copiedLabel.font = UIFont.preferredFont(forTextStyle: .body)
        copiedLabel.textAlignment = .center
        copiedLabel.numberOfLines = 1
        backgroundView.clipsToBounds = true
        backgroundView.layer.cornerRadius = 12.0
        backgroundView.layer.opacity = 0.0
        backgroundView.contentView.addSubview(copiedLabel)
        copiedLabel.translatesAutoresizingMaskIntoConstraints = false
        copiedLabel.topAnchor.constraint(equalTo: backgroundView.contentView.topAnchor, constant: 10).isActive = true
        copiedLabel.bottomAnchor.constraint(equalTo: backgroundView.contentView.bottomAnchor, constant: -10).isActive = true
        copiedLabel.leftAnchor.constraint(equalTo: backgroundView.contentView.leftAnchor, constant: 10).isActive = true
        copiedLabel.rightAnchor.constraint(equalTo: backgroundView.contentView.rightAnchor, constant: -10).isActive = true
        navigationController!.view.addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.centerXAnchor.constraint(equalTo: navigationController!.view.centerXAnchor).isActive = true
        backgroundView.centerYAnchor.constraint(equalTo: navigationController!.view.centerYAnchor).isActive = true
        UIView.animate(withDuration: 0.25, delay: 0.0, options: []) {
            backgroundView.layer.opacity = 1.0
        } completion: { _ in
            UIView.animate(withDuration: 0.25, delay: 0.5, options: []) {
                backgroundView.layer.opacity = 0.0
            } completion: { _ in
                backgroundView.removeFromSuperview()
            }
            
        }
    }
    
    // MARK: HandlesCellTextField
    
    func handleTextField() {
        if let view = view.viewWithTag(currentViewTag + 100) as? UITextField {
            log("Handling text field should return with tag \(currentViewTag).")
            currentViewTag += 100
            view.becomeFirstResponder()
        } else {
            log("Text field with tag \(currentViewTag + 100) not found.")
            currentViewTag = 0
            view.endEditing(false)
        }
    }
    
    func handleTextFieldBeginEditing(_ sender: UITextField) {
        log("Text field with tag \(sender.tag) started editing.")
        currentViewTag = sender.tag
    }
    
    // MARK: Helper Functions
    
    @objc func updateOTP() {
        time = 30 - (Calendar.current.component(.second, from: Date()) % 30)
        if userProfile != nil {
            tableView.reloadRows(at: [IndexPath(row: 0, section: 4)], with: .none)
        } else {
            otp = nil
        }
    }
    
}
