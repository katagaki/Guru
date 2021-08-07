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
    
    // Linguistic features in passwords
    public var freqCharacters: [String:Double] = [:] {
        didSet { setValue(freqCharacters, forKey: "profile_freqCharacters", hasAuth: false, ignoresFunction: openingFromKeychain) }
    }
    public var freqWords: [String:Double] = [:] {
        didSet { setValue(freqWords, forKey: "profile_freqWords", hasAuth: false, ignoresFunction: openingFromKeychain) }
    }
    public var avgWordLength: Double = 0 {
        didSet { setValue(avgWordLength, forKey: "profile_avgWordLength", hasAuth: false, ignoresFunction: openingFromKeychain) }
    }
    
    // Usage habits of characters
    public var freqUppercase: Double = 0 {
        didSet { setValue(freqUppercase, forKey: "profile_freqUppercase", hasAuth: false, ignoresFunction: openingFromKeychain) }
    }
    public var freqUppercaseCount: Int = 0 {
        didSet { setValue(freqUppercaseCount, forKey: "profile_freqUppercase_Count", hasAuth: false, ignoresFunction: openingFromKeychain) }
    }
    public var freqLowercase: Double = 0 {
        didSet { setValue(freqLowercase, forKey: "profile_freqLowercase", hasAuth: false, ignoresFunction: openingFromKeychain) }
    }
    public var freqLowercaseCount: Int = 0 {
        didSet { setValue(freqLowercaseCount, forKey: "profile_freqLowercase_Count", hasAuth: false, ignoresFunction: openingFromKeychain) }
    }
    public var freqNumbers: Double = 0 {
        didSet { setValue(freqNumbers, forKey: "profile_freqNumbers", hasAuth: false, ignoresFunction: openingFromKeychain) }
    }
    public var freqNumbersCount: Int = 0 {
        didSet { setValue(freqNumbersCount, forKey: "profile_freqNumbers_Count", hasAuth: false, ignoresFunction: openingFromKeychain) }
    }
    public var freqSymbols: Double = 0 {
        didSet { setValue(freqSymbols, forKey: "profile_freqSymbols", hasAuth: false, ignoresFunction: openingFromKeychain) }
    }
    public var freqSymbolsCount: Int = 0 {
        didSet { setValue(freqSymbolsCount, forKey: "profile_freqSymbols_Count", hasAuth: false, ignoresFunction: openingFromKeychain) }
    }
    public var freqLeet: Double = 0 {
        didSet { setValue(freqLeet, forKey: "profile_freqLeet", hasAuth: false, ignoresFunction: openingFromKeychain) }
    }
    public var freqLeetCount: Int = 0 {
        didSet { setValue(freqLeetCount, forKey: "profile_freqLeet_Count", hasAuth: false, ignoresFunction: openingFromKeychain) }
    }
    
    // Usage habits of keyboard runs
    public var freqRunningLetters: Double = 0 {
        didSet { setValue(freqRunningLetters, forKey: "profile_freqRunningLetters", hasAuth: false, ignoresFunction: openingFromKeychain) }
    }
    public var freqRunningNumbers: Double = 0 {
        didSet { setValue(freqRunningNumbers, forKey: "profile_freqRunningNumbers", hasAuth: false, ignoresFunction: openingFromKeychain) }
    }
    
    // Count of use of symbols
    public var preferredSymbols: [String:Int] = [:] {
        didSet { setValue(preferredSymbols, forKey: "profile_preferredSymbols", hasAuth: false, ignoresFunction: openingFromKeychain) }
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
                    log("Adding \(keychainItem.key) to data point array.")
                    keychainItems.append(keychainItem)
                }
                
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
                        
                        // Password linguistic features
                    case "profile_freqCharacters":
                        if let dictionary = try? JSONDecoder().decode([String:Double].self, from: value.data(using: .utf8)!) {
                            freqCharacters = dictionary
                        }
                    case "profile_freqWords":
                        if let dictionary = try? JSONDecoder().decode([String:Double].self, from: value.data(using: .utf8)!) {
                            freqWords = dictionary
                        }
                    case "profile_avgWordLength": avgWordLength = Double(value) ?? 0.0
                        
                        // Usage habits of characters
                    case "profile_freqUppercase": freqUppercase = Double(value) ?? 0.0
                    case "profile_freqUppercase_count": freqUppercaseCount = Int(value) ?? 0
                    case "profile_freqLowercase": freqLowercase = Double(value) ?? 0.0
                    case "profile_freqLowercase_count": freqLowercaseCount = Int(value) ?? 0
                    case "profile_freqNumbers": freqNumbers = Double(value) ?? 0.0
                    case "profile_freqNumbers_count": freqNumbersCount = Int(value) ?? 0
                    case "profile_freqSymbols": freqSymbols = Double(value) ?? 0.0
                    case "profile_freqSymbols_count": freqSymbolsCount = Int(value) ?? 0
                    case "profile_freqLeet": freqLeet = Double(value) ?? 0.0
                    case "profile_freqLeet_count": freqLeetCount = Int(value) ?? 0
                        
                        // Usage habits of keyboard runs
                    case "profile_freqRunningLetters": freqRunningLetters = Double(value) ?? 0.0
                    case "profile_freqRunningNumbers": freqRunningNumbers = Double(value) ?? 0.0
                        
                        // Use of symbols
                    case "profile_preferredSymbols":
                        if let dictionary = try? JSONDecoder().decode([String:Int].self, from: value.data(using: .utf8)!) {
                            preferredSymbols = dictionary
                        }
                        
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
                
                log("User profile open function is returning NOW!")
                
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
        setValue(freqCharacters, forKey: "profile_freqCharacters", hasAuth: false)
        setValue(freqWords, forKey: "profile_freqWords", hasAuth: false)
        setValue(avgWordLength, forKey: "profile_avgWordLength", hasAuth: false)
        setValue(freqUppercase, forKey: "profile_freqUppercase", hasAuth: false)
        setValue(freqLowercase, forKey: "profile_freqLowercase", hasAuth: false)
        setValue(freqNumbers, forKey: "profile_freqNumbers", hasAuth: false)
        setValue(freqSymbols, forKey: "profile_freqSymbols", hasAuth: false)
        setValue(freqLeet, forKey: "profile_freqLeet", hasAuth: false)
        setValue(freqRunningLetters, forKey: "profile_freqRunningLetters", hasAuth: false)
        setValue(freqRunningNumbers, forKey: "profile_freqRunningNumbers", hasAuth: false)
        setValue(preferredSymbols, forKey: "profile_preferredSymbols", hasAuth: false)
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
    
    public func frequency(ofCharacter char: String) -> Double {
        if let index = freqCharacters.index(forKey: char) {
            return freqCharacters[index].value
        } else {
            return 0
        }
        
    }
    
    public func frequency(ofWord word: String) -> Double {
        if let index = freqWords.index(forKey: word) {
            return freqWords[index].value
        } else {
            return 0
        }
    }
    
    public func preference(forSymbol symbol: String) -> Int {
        if let index = preferredSymbols.index(forKey: symbol) {
            return preferredSymbols[index].value
        } else {
            return 0
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
    
    // MARK: CSV
    
    func csv(ofType type: CSVType) -> String {
        
        var csvContents: String = ""
        var dataPoints: [String] = []
        
        log("Starting to create \(type) CSV.")
        
        // Set the header for the CSV
        switch type {
        case .Guru:
            csvContents = "Name,LoginURL,ResetURL,Username,Password,OTPSecret"
        case .Chromium:
            csvContents = "Name,Url,Username,Password"
        case .Safari:
            csvContents = "Title,Url,Username,Password,OTPAuth"
        case .OnePassword:
            csvContents = "Title,Website,Username,Password"
        case .None: break
        }
        
        // Set the positions of the data
        switch type {
        case .Guru:
            dataPoints.append("accountName")
            dataPoints.append("loginURL")
            dataPoints.append("passwordResetURL")
            dataPoints.append("username")
            dataPoints.append("password")
            dataPoints.append("totpSecret")
        case .Chromium, .OnePassword:
            dataPoints.append("accountName")
            dataPoints.append("domain")
            dataPoints.append("username")
            dataPoints.append("password")
        case .Safari:
            dataPoints.append("accountName")
            dataPoints.append("domain")
            dataPoints.append("username")
            dataPoints.append("password")
            dataPoints.append("totpSecret")
        case .None: break
        }
        
        // Enumeratre through logins and add data
        for login in logins {
            csvContents += "\n"
            for dataPoint in dataPoints {
                var dataPointText: String = ""
                switch dataPoint {
                case "accountName": dataPointText = login.accountName ?? ""
                case "loginURL": dataPointText = login.loginURL ?? ""
                case "passwordResetURL": dataPointText = login.passwordResetURL ?? ""
                case "username": dataPointText = login.username ?? ""
                case "password": dataPointText = login.password ?? ""
                case "totpSecret": dataPointText = login.totpSecret ?? ""
                case "domain":
                    if let loginURL = login.loginURL, loginURL != "" {
                        var url = loginURL
                        if !url.starts(with: "https://") && !url.starts(with: "http://") {
                            url = "https://\(url)"
                        }
                        if let url = URL(string: url) {
                            dataPointText = url.host ?? ""
                        }
                    }
                default: log("Unsupported data point: \(dataPoint)")
                }
                // Handle delimiters
                if dataPointText.contains("\"") || dataPointText.contains(",") {
                    dataPointText = dataPointText.replacingOccurrences(of: "\"", with: "\"\"")
                    dataPointText = "\"\(dataPointText)\""
                }
                // Add the data point
                csvContents += dataPointText
                // Add comma if not last item
                if dataPoints.last != dataPoint {
                    csvContents += ","
                }
            }
        }
        
        log("CSV generated successfully.")
        log(csvContents)
        
        return csvContents
    }
    
    func addLogins(fromCSV contents: String, progressReporter: ReportsProgress? = nil) -> (success: Bool, notImportedCount: Int) {
        
        let queue = DispatchQueue(label: "UserProfile.addLogins", attributes: .concurrent)
        let csvByLines: [String] = contents.components(separatedBy: .newlines)
        var csvType: CSVType = .None
        var dataPoints: [String] = []
        var notImportedCount: Int = 0
        var progress: Int = 0
        
        log("Starting to load CSV.")
        
        // Set the header for the CSV
        switch csvByLines[0].lowercased() {
        case "name,loginurl,reseturl,username,password,otpsecret":
            csvType = .Guru
        case "name,url,username,password":
            csvType = .Chromium
        case "title,url,username,password,otpauth":
            csvType = .Safari
        case "title,website,username,password":
            csvType = .OnePassword
        default:
            csvType = .None
            return (false, csvByLines.count - 1)
        }
        
        // Set the positions of the data
        switch csvType {
        case .Guru:
            dataPoints.append("accountName")
            dataPoints.append("loginURL")
            dataPoints.append("passwordResetURL")
            dataPoints.append("username")
            dataPoints.append("password")
            dataPoints.append("totpSecret")
        case .Chromium, .OnePassword:
            dataPoints.append("accountName")
            dataPoints.append("domain")
            dataPoints.append("username")
            dataPoints.append("password")
        case .Safari:
            dataPoints.append("accountName")
            dataPoints.append("domain")
            dataPoints.append("username")
            dataPoints.append("password")
            dataPoints.append("totpSecret")
        case .None: break
        }
        
        // Parse CSV line
        DispatchQueue.concurrentPerform(iterations: csvByLines.count - 1) { i in
            let semaphore = DispatchSemaphore(value: 0)
            
            // Parse CSV
            let splitLines: [String] = csvByLines[i + 1].components(separatedBy: ",")
            var currentIndex: Int = 0
            var currentString: String = ""
            var lastStringHadStartAnchor: Bool = false
            var willAddDataPoint: Bool = false
            let login = Login()
            
            if splitLines.count < dataPoints.count {
                
            } else {
                for splitString in splitLines {
                    if lastStringHadStartAnchor, splitString.hasSuffix("\"") {
                        currentString += "," + String(splitString.dropLast())
                        lastStringHadStartAnchor = false
                        willAddDataPoint = true
                    } else if lastStringHadStartAnchor, !splitString.hasSuffix("\"") {
                        currentString += "," + splitString
                    } else if !lastStringHadStartAnchor, splitString.hasPrefix("\"") {
                        currentString = String(splitString.dropFirst())
                        currentString = currentString.replacingOccurrences(of: "\"\"", with: "\"")
                        lastStringHadStartAnchor = true
                    } else if !lastStringHadStartAnchor, !splitString.hasPrefix("\"") {
                        currentString = splitString
                        currentString = currentString.replacingOccurrences(of: "\"\"", with: "\"")
                        lastStringHadStartAnchor = false
                        willAddDataPoint = true
                    }
                    if willAddDataPoint {
                        let dataPointText: String = dataPoints[currentIndex]
                        switch dataPointText {
                        case "accountName":
                            switch csvType {
                            case .Guru, .Chromium, .OnePassword:
                                login.accountName = currentString
                            case .Safari:
                                login.accountName = currentString.components(separatedBy: " ")[0]
                            case .None: break
                            }
                        case "loginURL": login.loginURL = (currentString == "" ? nil : currentString)
                        case "domain": login.loginURL = (currentString == "" ? nil : currentString)
                        case "passwordResetURL": login.passwordResetURL = (currentString == "" ? nil : currentString)
                        case "username": login.username = (currentString == "" ? nil : currentString)
                        case "password": login.password = currentString
                        case "totpSecret": login.totpSecret = (currentString == "" ? nil : parseOTP(code: currentString))
                        default: log("Unsupported data point: \(dataPointText)")
                        }
                        currentString = ""
                        currentIndex += 1
                        willAddDataPoint = false
                    }
                }
                
                if !logins.contains(where: { existingLogin in
                    return existingLogin.accountName == login.accountName
                }) {
                    // Set login icon
                    login.setAccountIcon {
                        semaphore.signal()
                    }
                    semaphore.wait()
                    
                    if !logins.contains(where: { existingLogin in
                        return existingLogin.accountName == login.accountName
                    }) {
                        // Add login
                        queue.async(flags: .barrier) {
                            self.add(login: login)
                        }
                    } else {
                        notImportedCount += 1
                        log("Login already exists, will not replace.")
                    }
                } else {
                    notImportedCount += 1
                    log("Login already exists, will not replace.")
                }
                queue.sync(flags: .barrier) {
                    log("Finished processing login at index \(i).")
                    // Report progress
                    if let progressReporter = progressReporter {
                        progress += 1
                        progressReporter.updateProgress(progress: Double(progress), total: Double(csvByLines.count - 1))
                    }
                }
            }
            
        }
        
        return (true, notImportedCount)
    }
    
    // MARK: Import Data
    
    func importTwitter(data: TwitterData, progressReporter: ReportsProgress? = nil) -> (success: Bool, notImportedCount: Int) {
        
        var currentCount: Int = 0
        var dataPointCount: Int = 0
        
        if data.languages != nil { dataPointCount += data.languages!.count }
        if data.interests != nil { dataPointCount += data.interests!.count }
        if data.shows != nil { dataPointCount += data.shows!.count }
        
        if let languages = data.languages {
            for language in languages {
                if let name = language.language,
                    let isDisabled = language.isDisabled,
                   (!name.containsNonLatinCharacters() && !isDisabled),
                   builtInLanguages.contains(where: { builtInLanguage in
                    return name.lowercased().contains(builtInLanguage.lowercased())
                }),
                   !self.languages.contains(name.capitalized) {
                    log("Appending \(name.lowercased()) to languages.")
                    self.languages.append(name.capitalized)
                }
                currentCount += 1
                progressReporter?.updateProgress(progress: Double(currentCount), total: Double(dataPointCount))
            }
        }
        
        if let interests = data.interests {
            for interest in interests {
                if let name = interest.name,
                    let isDisabled = interest.isDisabled,
                   (!name.containsNonLatinCharacters() && !isDisabled) {
                    if let newInterest = builtInInterests.first(where: { builtInInterest in
                        return name.lowercased() == builtInInterest.name.lowercased() || builtInInterest.words.contains(where: { word in
                            return word.lowercased() == name.lowercased()
                        })
                    }),
                        !self.interests.contains(newInterest.name.lowercased()) {
                        log("Appending \(name.lowercased()) to interests.")
                        self.interests.append(newInterest.name.lowercased())
                    }
                }
                currentCount += 1
                progressReporter?.updateProgress(progress: Double(currentCount), total: Double(dataPointCount))
            }
        }
        
        if let shows = data.shows {
            for show in shows {
                if !show.containsNonLatinCharacters() {
                    if preferredWords.keys.contains(show.lowercased()) {
                        let count: Int = preferredWords[show.lowercased()]!
                        log("Updating \(show.lowercased()) to preferred words with count \(count + 1).")
                        preferredWords.updateValue(count + 1, forKey: show.lowercased())
                    } else {
                        log("Adding \(show.lowercased()) to preferred words with count 1.")
                        preferredWords.updateValue(1, forKey: show.lowercased())
                    }
                }
                currentCount += 1
                progressReporter?.updateProgress(progress: Double(currentCount), total: Double(dataPointCount))
            }
        }
        
        return (true, dataPointCount - currentCount)
        
    }
    
    // MARK: Helper Functions
    
    func loginKey(accountName: String) -> String {
        let data = Data(accountName.utf8)
        return "login_" + SHA256.hash(data: data).string().lowercased()
    }
    
    public override var description: String {
        return """
        --- User Profile Object Descriptor ---
        
        > Basic Information
        Full Name: \(fullName ?? "nil")
        Region: \(region ?? "nil")
        Languages\(languages)
        Age: \(birthdayString() ?? "nil")
        Company Name: \(companyName ?? "nil")
        School Name: \(schoolName ?? "nil")
        Logins:
        \(logins)
        
        --- Prediction Profile  ---
        
        > Linguistic Features
        Frequent Characters:
        \(freqCharacters.description)
        Frequent Words:
        \(freqWords.description)
        Average Word Length: \(avgWordLength)
        
        > Usage Habits
        Frequency of Uppercase Letters: \(freqUppercase)
        Frequency of Lowercase Letters: \(freqLowercase)
        Frequency of Numbers: \(freqNumbers)
        Frequency of Symbols: \(freqSymbols)
        Frequency of Leet: \(freqLeet)
        Frequency of Running Letters: \(freqRunningLetters)
        Frequency of Running Numbers: \(freqRunningNumbers)
        
        > Preferences
        Preferred Symbols:
        \(preferredSymbols.description)
        Interests:
        \(interests.description)
        Preferred Words:
        \(preferredWords.description)
        """
    }
    
}
