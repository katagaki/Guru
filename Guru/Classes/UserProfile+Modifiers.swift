//
//  UserProfile+Setters.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/08/08.
//

import UIKit

extension UserProfile {
    
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
    
    // MARK: Removers
    
    public func remove(login accountName: String) {
        log("Removing \(loginKey(accountName: accountName)).")
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
    
}
