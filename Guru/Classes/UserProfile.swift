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
