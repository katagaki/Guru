//
//  UserProfile.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/06/26.
//

import CryptoKit
import Foundation
import KeychainAccess
import LocalAuthentication
import UIKit

public class UserProfile: NSObject {
    
    let keychainServiceName: String = "YYM4Z6MU8F.com.yorigami.Guru"
    let keychainAccessGroup: String = "group.yorigami.Guru"
        
    let dateFormatter: DateFormatter = DateFormatter()
    
    var keychain: Keychain?
    var keychainNoPolicy: Keychain?
    var currentBiometryType: LABiometryType = .none
    var isSynchronizable: Bool = false
    
    var openingFromKeychain: Bool = false
    
    // Basic information
    public var fullName: String? {
        didSet { setValue(fullName, forKey: "profile_fullName", hasAuth: false, ignoresFunction: openingFromKeychain) }
    }
    public var region: String? {
        didSet { setValue(region, forKey: "profile_region", hasAuth: false, ignoresFunction: openingFromKeychain) }
    }
    public var languages: [String] = [] {
        didSet { setValue(languages, forKey: "profile_languages", hasAuth: false, ignoresFunction: openingFromKeychain) }
    }
    public var birthday: Date? {
        didSet { setValue(birthday, forKey: "profile_birthday", hasAuth: false, ignoresFunction: openingFromKeychain) }
    }
    public var companyName: String? {
        didSet { setValue(companyName, forKey: "profile_companyName", hasAuth: false, ignoresFunction: openingFromKeychain) }
    }
    public var schoolName: String? {
        didSet { setValue(schoolName, forKey: "profile_schoolName", hasAuth: false, ignoresFunction: openingFromKeychain) }
    }
    
    // Automatically learned behavior
    public var interests: [String] = [] {
        didSet { setValue(interests, forKey: "profiles_interests", hasAuth: false, ignoresFunction: openingFromKeychain) }
    }
    public var preferredWords: [String:Int] = [:] {
        didSet { setValue(preferredWords, forKey: "profile_preferredWords", hasAuth: false, ignoresFunction: openingFromKeychain) }
    }
    
    // User logins
    public var logins: [Login] = []
    
    public override init() {
        super.init()
        dateFormatter.dateFormat = "yyyy/MM/dd"
    }
    
    public init(usesBiometryType biometryType: LABiometryType, syncsWithiCloud synchronizable: Bool) {
        super.init()
        setBiometryType(biometryType: biometryType)
        setSynchronizable(synchronizable: synchronizable)
        prepareKeychains()
    }
    
    // MARK: Keychain Actions
    
    public func setSynchronizable(synchronizable: Bool) {
        log("Setting synchronicity: \(synchronizable).")
        isSynchronizable = synchronizable
    }
    
    public func setBiometryType(biometryType: LABiometryType) {
        log("Setting biometry type: \(biometryType.rawValue).")
        currentBiometryType = biometryType
    }
    
    public func prepareKeychains() {
        
        // Set the keychain biometry type
        log("Preparing keychain for user profile.")
        switch currentBiometryType {
        case .faceID:
            log("Setting biometry mode to Face ID for user profile keychain.")
            keychain = Keychain(service: keychainServiceName, accessGroup: keychainAccessGroup).accessibility(.whenUnlocked, authenticationPolicy: .userPresence).authenticationPrompt(NSLocalizedString("SystemAuthenticationPromptFaceID", comment: "Authentication"))
        case .touchID:
            log("Setting biometry mode to Touch ID for user profile keychain.")
            keychain = Keychain(service: keychainServiceName, accessGroup: keychainAccessGroup).accessibility(.whenUnlocked, authenticationPolicy: .biometryAny).authenticationPrompt(NSLocalizedString("SystemAuthenticationPromptTouchID", comment: "Authentication"))
        case .none:
            log("Setting biometry mode to None for user profile keychain.")
            keychain = Keychain(service: keychainServiceName, accessGroup: keychainAccessGroup).accessibility(.whenUnlocked, authenticationPolicy: .devicePasscode)
        @unknown default:
            log("Setting biometry mode to Unknown for user profile keychain.")
            keychain = Keychain(service: keychainServiceName, accessGroup: keychainAccessGroup).accessibility(.always, authenticationPolicy: .applicationPassword)
        }
        
        // Set the keychain (no policy)
        log("Preparing un-policied keychain for user profile.")
        keychainNoPolicy = Keychain(service: keychainServiceName, accessGroup: keychainAccessGroup).accessibility(.whenUnlocked)
        
        // Set the keychain sync type
        if let keychain = keychain, let keychainNoPolicy = keychainNoPolicy {
            log("Setting keychain sync mode to \(isSynchronizable).")
            self.keychain = keychain.synchronizable(isSynchronizable)
            self.keychainNoPolicy = keychainNoPolicy.synchronizable(isSynchronizable)
        } else {
            log("Keychain not initialized while setting keychain sync mode!")
        }
        
    }
    
    public func new() {
        log("Creating new profile.")
        delete()
        UserProfile(usesBiometryType: currentBiometryType, syncsWithiCloud: isSynchronizable).save()
    }
    
    public func `open`() -> Bool {
        
        if let keychain = keychain {
            
            log("Opening user profile from keychain.")
            
            let keychainItemKeyValuePairs = keychain.allItems()
            
            if keychainItemKeyValuePairs.count == 0 {
                log("No items found in keychain, user may have cancelled authentication, or keychain settings may be invalid.")
                return false
            } else {
                let queue = DispatchQueue(label: "UserProfile.open", attributes: .concurrent)
                var keychainItems: [KeychainItem] = []
                for keychainItemKeyValuePair in keychainItemKeyValuePairs {
                    let keychainItem: KeychainItem = KeychainItem()
                    for (key, value) in keychainItemKeyValuePair {
                        switch key {
                        case "key": keychainItem.key = value as! String
                        case "value": keychainItem.value = value as! String
                        default: break
                        }
                    }
                    keychainItems.append(keychainItem)
                }
                log("Found \(keychainItems.count) keychain item(s).")
                
                openingFromKeychain = true
                
                logins.removeAll()
                DispatchQueue.concurrentPerform(iterations: keychainItems.count) { i in
                    let key = keychainItems[i].key
                    let value = keychainItems[i].value
                    switch key {
                        
                        // Basic information
                    case "profile_fullName": fullName = value
                    case "profile_region": region = value
                    case "profile_languages":
                        if value != "" {
                            languages = value.components(separatedBy: ",")
                        } else {
                            languages = []
                        }
                    case "profile_birthday":
                        if let date = dateFormatter.date(from: value) {
                            birthday = date
                        }
                    case "profile_companyName": companyName = value
                    case "profile_schoolName": schoolName = value
                    
                        // Automatically learned behavior
                    case "profiles_interests":
                        if value != "" {
                            interests = value.components(separatedBy: ",").sorted()
                        } else {
                            interests = []
                        }
                    case "profile_preferredWords":
                        if let dictionary = try? JSONDecoder().decode([String:Int].self, from: value.data(using: .utf8)!) {
                            preferredWords = dictionary
                        }
                        
                    case "internal_profileAccessed":
                        log("User profile was last accessed \(value).")
                        
                    case "internal_profileModified":
                        log("User profile was last modified \(value).")
                        
                    default:
                        if key.starts(with: "login_") {
                            if let login = try? JSONDecoder().decode(Login.self, from: value.data(using: .utf8)!) {
                                queue.async(flags: .barrier) {
                                    self.logins.append(login)
                                }
                            }
                        }
                        
                    }
                }
                
                queue.sync(flags: .barrier) {
                    self.logins.sort { a, b in
                        a.accountName!.lowercased() < b.accountName!.lowercased()
                    }
                    log("A total of \(self.logins.count) login(s) were loaded.")
                    self.logAccess()
                    log("Opened user profile from Keychain.")
                    self.openingFromKeychain = false
                }
                
                log("User profile open function is returning now!")
                
                return true
                
            }
        } else {
            log("Keychain not initialized while opening user profile!")
            return false
        }
    }
    
    public func save() {
        
        log("Saving user profile to keychain (replaces existing profile).")
        
        delete()
        
        setValue(fullName, forKey: "profile_fullName", hasAuth: false)
        setValue(region, forKey: "profile_region", hasAuth: false)
        setValue(region, forKey: "profile_region", hasAuth: false)
        setValue(languages, forKey: "profile_languages", hasAuth: false)
        setValue(birthday, forKey: "profile_birthday", hasAuth: false)
        setValue(companyName, forKey: "profile_companyName", hasAuth: false)
        setValue(schoolName, forKey: "profile_schoolName", hasAuth: false)
        setValue(interests, forKey: "profiles_interests", hasAuth: false)
        setValue(preferredWords, forKey: "profile_preferredWords", hasAuth: false)
        
        for login in logins {
            if let accountName = login.accountName {
                setValue(try? JSONEncoder().encode(login), forKey: "login_\(accountName)", hasAuth: true)
            }
        }
        
        logModification()
        
    }
    
    public func delete() {
        
        // Remove all keychain items from previous builds
        do {
            try Keychain(service: "com.yorigami.Guru").removeAll()
        } catch {
            log("Could not delete old keychain data. This is normal, as old keychain data may not be present.")
        }
        
        // Remove all keychain items from current/similar builds
        if let keychain = keychain {
            do {
                try keychain.removeAll()
            } catch {
                log("Could not delete keychain data.")
            }
        } else {
            log("Keychain not initialized while deleting keychain data!")
        }

    }
    
    func logAccess() {
        remove(key: "internal_profileAccessed")
        setValue("\(Int(Date().timeIntervalSince1970))", forKey: "internal_profileAccessed", hasAuth: true)
    }
    
    func logModification() {
        remove(key: "internal_profileModified")
        setValue("\(Int(Date().timeIntervalSince1970))", forKey: "internal_profileModified", hasAuth: true)
    }
    
    // MARK: Getters
    
    public func birthdayString() -> String? {
        if let birthday = birthday {
            return dateFormatter.string(from: birthday)
        } else {
            return nil
        }
    }
    
    public func language(_ name: String) -> String? {
        return languages.first { language in
            return language == name
        }
    }
    
    public func preference(forWord word: String) -> Int? {
        return preferredWords.first { (key, value) in
            return key == word
        }?.value
    }
    
    public func login(withName name: String) -> Login? {
        return logins.first { login in
            return login.accountName == name
        }
    }
    
    // MARK: Adders
    
    public func add(login accountName: String, accountIcon: UIImage, username: String, password: String, totpSecret: String, loginURL: String, passwordResetURL: String) {
        let login: Login = Login()
        login.accountName = accountName
        login.setAccountIcon(newIcon: accountIcon)
        login.username = username
        login.password = password
        login.totpSecret = totpSecret
        login.loginURL = loginURL
        login.passwordResetURL = passwordResetURL
        add(login: login)
    }
    
    public func add(login: Login) {
        if let accountName = login.accountName {
            setValue(login, forAccount: accountName, hasAuth: true)
            logins.append(login)
            logins.sort { a, b in
                a.accountName! < b.accountName!
            }
        }
    }
    
    // MARK: Setters
    
    public func set(birthday: String) {
        if let date = dateFormatter.date(from: birthday) {
            self.birthday = date
        }
    }
    
    public func setLoginProperty(forAccount name: String, accountName: String) {
        if let login = logins.first(where: { login in
            return login.accountName == name
        }) {
            login.accountName = accountName
            remove(key: loginKey(accountName: name))
            setValue(login, forAccount: accountName, hasAuth: true)
        }
    }
    
    public func setLoginProperty(forAccount name: String, accountIcon: UIImage) {
        if let login = logins.first(where: { login in
            return login.accountName == name
        }) {
            login.setAccountIcon(newIcon: accountIcon)
            remove(key: loginKey(accountName: name))
            setValue(login, forAccount: name, hasAuth: true)
        }
    }
    
    public func setLoginProperty(forAccount name: String, username: String) {
        if let login = logins.first(where: { login in
            return login.accountName == name
        }) {
            login.username = username
            remove(key: loginKey(accountName: name))
            setValue(login, forAccount: name, hasAuth: true)
        }
    }
    
    public func setLoginProperty(forAccount name: String, password: String) {
        if let login = logins.first(where: { login in
            return login.accountName == name
        }) {
            login.password = password
            remove(key: loginKey(accountName: name))
            setValue(login, forAccount: name, hasAuth: true)
        }
    }
    
    public func setLoginProperty(forAccount name: String, totpSecret: String) {
        if let login = logins.first(where: { login in
            return login.accountName == name
        }) {
            login.totpSecret = totpSecret
            remove(key: loginKey(accountName: name))
            setValue(login, forAccount: name, hasAuth: true)
        }
    }
    
    public func setLoginProperty(forAccount name: String, loginURL: String) {
        if let login = logins.first(where: { login in
            return login.accountName == name
        }) {
            login.loginURL = loginURL
            remove(key: loginKey(accountName: name))
            setValue(login, forAccount: name, hasAuth: true)
        }
    }
    
    public func setLoginProperty(forAccount name: String, passwordResetURL: String) {
        if let login = logins.first(where: { login in
            return login.accountName == name
        }) {
            login.passwordResetURL = passwordResetURL
            remove(key: loginKey(accountName: name))
            setValue(login, forAccount: name, hasAuth: true)
        }
    }
    
    func setValue(_ value: String?, forKey key: String, hasAuth: Bool, ignoresFunction: Bool = false) {
        if !ignoresFunction {
            switch hasAuth {
            case true:
                if let keychain = keychain {
                    if let value = value {
                        do {
                            try keychain.set(value, key: key)
                            log("Value was set for \(key) on authenticated keychain.")
                        } catch {
                            log("Could not set value in keychain: \(error.localizedDescription).")
                        }
                    } else {
                        try! keychain.remove(key)
                        log("Value for \(key) is null, removed from authenticated keychain.")
                    }
                } else {
                    log("Authenticated keychain not initialized while setting value for key \(key)!")
                }
            case false:
                if let keychainNoPolicy = keychainNoPolicy {
                    if let value = value {
                        try! keychainNoPolicy.set(value, key: key)
                        log("Value was set for \(key) on non-authenticated keychain.")
                    } else {
                        try! keychainNoPolicy.remove(key)
                        log("Value for \(key) is null, removed from non-authenticated keychain.")
                    }
                } else {
                    log("Non-authenticated keychain not initialized while setting value for key \(key)!")
                }
            }
        }
    }
    
    func setValue(_ value: Int, forKey key: String, hasAuth: Bool, ignoresFunction: Bool = false) {
        setValue(String(value), forKey: key, hasAuth: hasAuth, ignoresFunction: ignoresFunction)
    }
    
    func setValue(_ value: Double, forKey key: String, hasAuth: Bool, ignoresFunction: Bool = false) {
        setValue(String(value), forKey: key, hasAuth: hasAuth, ignoresFunction: ignoresFunction)
    }
    
    func setValue(_ value: [String], forKey key: String, hasAuth: Bool, ignoresFunction: Bool = false) {
        setValue(value.joined(separator: ","), forKey: key, hasAuth: hasAuth, ignoresFunction: ignoresFunction)
    }
    
    func setValue(_ value: [String:Int], forKey key: String, hasAuth: Bool, ignoresFunction: Bool = false) {
        setValue(try? JSONEncoder().encode(value), forKey: key, hasAuth: hasAuth, ignoresFunction: ignoresFunction)
    }
    
    func setValue(_ value: [String:Double], forKey key: String, hasAuth: Bool, ignoresFunction: Bool = false) {
        setValue(try? JSONEncoder().encode(value), forKey: key, hasAuth: hasAuth, ignoresFunction: ignoresFunction)
    }
    
    func setValue(_ value: Login, forAccount name: String, hasAuth: Bool, ignoresFunction: Bool = false) {
        setValue(try? JSONEncoder().encode(value), forKey: loginKey(accountName: name), hasAuth: hasAuth, ignoresFunction: ignoresFunction)
    }
    
    func setValue(_ value: Date?, forKey key: String, hasAuth: Bool, ignoresFunction: Bool = false) {
        if let value = value {
            setValue(dateFormatter.string(from: value), forKey: key, hasAuth: hasAuth, ignoresFunction: ignoresFunction)
        } else {
            setValue(nil as String?, forKey: key, hasAuth: hasAuth, ignoresFunction: ignoresFunction)
        }
    }
    
    func setValue(_ value: Data?, forKey key: String, hasAuth: Bool, ignoresFunction: Bool = false ) {
        if let value = value {
            setValue(String(data: value, encoding: .utf8), forKey: key, hasAuth: hasAuth, ignoresFunction: ignoresFunction)
        } else {
            setValue(nil as String?, forKey: key, hasAuth: hasAuth, ignoresFunction: ignoresFunction)
        }
    }
    
    // MARK: Removers
    
    public func remove(login accountName: String) {
        log("Removing login_\(accountName).")
        remove(key: loginKey(accountName: accountName))
        logins.removeAll { login in
            return login.accountName == accountName
        }
    }
    
    public func remove(key: String) {
        if let keychain = keychain {
            log("Removing key \(key).")
            do {
                try keychain.remove(key)
            } catch {
                log("Could not remove key \(key).")
            }
        } else {
            log("Keychain not initialized while removing key \(key)!")
        }
    }
    
    // MARK: Helper Functions
    
    func loginKey(accountName: String) -> String {
        let data = Data(accountName.utf8)
        return "login_" + SHA256.hash(data: data).string().lowercased()
    }
    
    public override var description: String {
        return """
        --- User Profile Object Descriptor ---
        
        Full Name: \(fullName ?? "nil")
        Region: \(region ?? "nil")
        Languages\(languages)
        Age: \(birthdayString() ?? "nil")
        Company Name: \(companyName ?? "nil")
        School Name: \(schoolName ?? "nil")
        
        Logins:
        \(logins)
        
        Interests:
        \(interests.description)
        
        Preferred Words:
        \(preferredWords.description)
        """
    }
    
}
