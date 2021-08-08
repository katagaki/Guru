//
//  UserProfile+Keychain.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/08/08.
//

import Foundation
import KeychainAccess
import LocalAuthentication

extension UserProfile {
    
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
    
}
