//
//  Pwned.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/04.
//

import CryptoKit
import Foundation

// MARK: Data

var emailPwnage: [String:[Pwnage]]?
var passwordPwnage: [String]?
var passwordReuse: [String]?

// MARK: Breaches API

/// Checks whether a set of emails have been breached.
/// - Parameter emails: The set of email addresses to check.
/// - Returns: Returns a dictionary of the email addresses and whether they have been breached, and the number of email addresses that could not be checked.
func checkBreaches(emails: [String]) -> (breaches: [String:[Pwnage]], errorCount: Int) {
    
    let semaphore = DispatchSemaphore(value: 0)
    
    let uniqueEmails: [String] = emails.unique()
    var result: [String:[Pwnage]] = [:]
    var errorCount: Int = 0

    for email in uniqueEmails {
        log("Checking email for breaches...")
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + .milliseconds(1500)) {
            checkBreaches(email: email) { breaches, hasError in
                if hasError {
                    errorCount += 1
                    semaphore.signal()
                } else {
                    if let breaches = breaches {
                        result.updateValue(breaches, forKey: email)
                        log("Added email to list of breached logins.")
                        semaphore.signal()
                    } else {
                        log("No breach detected on \(email.prefix(3))<redacted>.")
                        semaphore.signal()
                    }
                }
            }
        }
        semaphore.wait()
        log("Done checking email for breaches.")
    }
    
    return (result, errorCount)
    
}

/// Checks whether an email has been breached.
/// - Parameters:
///   - email: The email address to check.
///   - completion: Returns whether an email  has been breached, and whether an error occurred during the check.
func checkBreaches(email: String, completion: @escaping (_ breaches: [Pwnage]?, _ hasError: Bool) -> Void) {
        
    let url = URL(string: "https://haveibeenpwned.com/api/v3/breachedaccount/\(email)")!
    var request = URLRequest(url: url)
    request.setValue(apiKeys["hibp"], forHTTPHeaderField: "hibp-api-key")
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            log("Called breachedaccount API with error \(error.localizedDescription).")
            completion(nil, true)
        } else {
            if let data = data {
                if let response = response as? HTTPURLResponse {
                    if let rateLimitTimeout = response.value(forHTTPHeaderField: "retry-after") {
                        log("!! Called breachedaccount API with rate limit warning, will retry after \(rateLimitTimeout) seconds.")
                        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + .seconds(Int(rateLimitTimeout)!) + .milliseconds(100)) {
                            checkBreaches(email: email) { pwnage, hasError in
                                completion(pwnage, hasError)
                            }
                        }
                    } else {
                        if let pwnage = try? JSONDecoder().decode([Pwnage].self, from: data) {
                            log("Called breachedaccount API with valid response from HIBP.")
                            completion(pwnage, false)
                        } else {
                            completion(nil, false)
                        }
                    }
                }
            } else {
                log("Called breachedaccount API with unknown error.")
                completion(nil, false)
            }
        }
    }.resume()
    
}

// MARK: Pwned Passwords API

/// Checks whether a set of passwords have been breached.
/// - Parameter passwords: The set of passwords to check.
/// - Returns: Returns a dictionary of the passwords and whether they have been breached, and the number of passwords that could not be checked.
func checkBreaches(passwords: [String]) -> (breaches: [String: Bool], hasError: Int) {
    
    let queue = DispatchQueue(label: "UserProfile.addLogins", attributes: .concurrent)
    let uniquePasswords = passwords.unique()
    var dict: [String: Bool] = [:]
    var errorCount: Int = 0
    
    log("Checking passwords for breaches.")
    
    DispatchQueue.concurrentPerform(iterations: uniquePasswords.count) { i in
        let semaphore = DispatchSemaphore(value: 0)
        
        log("Checking password for breaches...")
        checkBreaches(password: uniquePasswords[i]) { breached, hasError in
            if hasError {
                errorCount += 1
                semaphore.signal()
            } else {
                if let breached = breached {
                    if breached == true {
                        queue.async(flags: .barrier) {
                            dict.updateValue(breached, forKey: uniquePasswords[i])
                            log("Added password \(i) to list of breached logins.")
                            semaphore.signal()
                        }
                    } else {
                        log("No breach detected on password \(i).")
                        semaphore.signal()
                    }
                }
            }
        }
        semaphore.wait()
        log("Done checking password \(i) for breaches.")
    }
    
    return (dict, errorCount)
    
}

/// Checks whether a password has been breached.
/// - Parameters:
///   - password: The password to check.
///   - completion: Returns whether a password has been breached, and whether an error occurred during the check.
func checkBreaches(password: String, completion: @escaping (_ breached: Bool?, _ hasError: Bool) -> Void) {
    
    let sha1Hash: String = Insecure.SHA1.hash(data: password.data(using: .utf8)!).hex.uppercased()
    let leftTrimHash: String = "" + sha1Hash.prefix(5)
    let rightTrimHash: String = sha1Hash.replacingOccurrences(of: leftTrimHash, with: "")
    
    let url = URL(string: "https://api.pwnedpasswords.com/range/\(leftTrimHash)")!
    var request = URLRequest(url: url)
    request.setValue(apiKeys["hibp"], forHTTPHeaderField: "hibp-api-key")
    request.setValue("true", forHTTPHeaderField: "Add-Padding")
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            log("Called range API with error \(error.localizedDescription).")
            completion(nil, true)
        } else {
            if let data = data {
                let pwnedPasswords = String(data: data, encoding: .utf8)!.components(separatedBy: CharacterSet.newlines)
                log("Called range API with \(pwnedPasswords.count) password(s) returned.")
                var passwordPwned: Bool = false
                for pwnedPassword in pwnedPasswords {
                    if pwnedPassword.starts(with: rightTrimHash) {
                        log("Found password hash in breach list.")
                        passwordPwned = true
                    }
                }
                completion(passwordPwned, false)
            } else {
                log("Called range API with unknown error.")
                completion(nil, false)
            }
        }
    }.resume()
    
}
