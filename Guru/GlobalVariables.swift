//
//  GlobalVariables.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/01.
//

import Foundation
import LocalAuthentication
import UIKit

// MARK: System Features

let defaults = UserDefaults.standard
let notifications = NotificationCenter.default
let files = FileManager.default
let laContext = LAContext()

// MARK: App Global Settings

var isFirstOpenOperationsDone: Bool = false

/// Enable debug options to enable the Delete Profile button on the lock screen.
let isDebugOptionsEnabled = false

// MARK: User Profile

var userProfile: UserProfile?

// MARK: Breach Detection

var emailPwnage: [String:[Pwnage]]?
var passwordPwnage: [String]?
var passwordReuse: [String]?

/// API keys are stored in a property list called APIKeys.plist
/// To add a HIBP key, create a new key value pair with the key 'hibp' with the value being the API key.
var apiKeys: [String:String] = [:]

// MARK: Generator Data

var interests: [Interest] = []
var languages: [String] = []
var words: [String] = []
var leetList: [String:String] = [:]
var runningSequences: [String] = []

// MARK: Load Functions

public func loadGlobalVariables() {
    
    // Load all resources concurrently to save time and synchronize before returning
    DispatchQueue.concurrentPerform(iterations: 6) { i in
        switch i {
        case 0: loadInterests()
        case 1: loadLanguages()
        case 2: loadWords()
        case 3: loadLeetlist()
        case 4: loadRunningSequences()
        case 5: loadAPIKeys()
        default: break
        }
    }
    
}

public func loadInterests() {
    let path = Bundle.main.path(forResource: "Interests", ofType: "json")!
    let interestsJSON = try! String(contentsOfFile: path, encoding: .utf8)
    let interestsJSONData = interestsJSON.data(using: .utf8)!
    interests = try! JSONDecoder().decode([Interest].self, from: interestsJSONData)
    interests.sort { a, b in
        a.name < b.name
    }
    interests.removeAll { interest in
        return interest.name == "__reserved"
    }
}

public func loadLanguages() {
    if let path = Bundle.main.path(forResource: "Languages", ofType: "txt"), let contents = try? String(contentsOfFile: path, encoding: .utf8) {
        log("Loading languages.")
        languages = contents.components(separatedBy: .newlines)
        languages.sort()
        log("\(languages.count) languages loaded.")
    } else {
        log("Could not load languages.")
    }
}

public func loadWords() {
    if let path = Bundle.main.path(forResource: "Wordlist", ofType: "txt"), let contents = try? String(contentsOfFile: path, encoding: .utf8) {
        log("Loading words.")
        words = contents.components(separatedBy: .newlines)
        words = words.filter({ word in
            return word.count >= 3
        })
        log("\(words.count) words loaded.")
    } else {
        log("Could not load words.")
    }
}

public func loadLeetlist() {
    if let path = Bundle.main.path(forResource: "Leetlist", ofType: "plist") {
        log("Loading leet list.")
        for (key, value) in NSDictionary(contentsOfFile: path)! {
            leetList[key as! String] = (value as! String)
        }
        log("\(leetList.count) leet characters loaded.")
    } else {
        log("Could not load leet property list.")
    }
}

public func loadRunningSequences() {
    if let path = Bundle.main.path(forResource: "RunningSequences", ofType: "plist"), let array = NSArray(contentsOfFile: path) as? [String] {
        log("Loading running sequences.")
        runningSequences = array
        log("\(runningSequences.count) running sequences loaded.")
    } else {
        log("Could not load running sequences property list.")
    }
}

public func loadAPIKeys() {
    if let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist") {
        log("Loading API keys.")
        for (key, value) in NSDictionary(contentsOfFile: path)! {
            apiKeys[key as! String] = (value as! String)
        }
        log("\(apiKeys.count) API keys loaded.")
    } else {
        log("Could not load API keys property list.")
    }
}
