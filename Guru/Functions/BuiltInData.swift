//
//  BuiltInData.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/08/06.
//

import Foundation

/// API keys are stored in a property list called APIKeys.plist
/// To add a HIBP key, create a new key value pair with the key 'hibp' with the value being the API key.
var apiKeys: [String:String] = [:]

// MARK: Data

var builtInInterests: [Interest] = []
var builtInLanguages: [String] = []
var builtInWords: [String] = []
var builtInLeetList: [String:String] = [:]
var builtInRunningSequences: [String] = []

var interestWordAverage: Double = 0

// MARK: Load Functions

func loadBuiltInData() {
    
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

func loadInterests() {
    let path = Bundle.main.path(forResource: "Interests", ofType: "json")!
    let interestsJSON = try! String(contentsOfFile: path, encoding: .utf8)
    let interestsJSONData = interestsJSON.data(using: .utf8)!
    var wordCount: Int = 0
    var characterCount: Int = 0
    log("Loading interests.")
    builtInInterests = try! JSONDecoder().decode([Interest].self, from: interestsJSONData)
    builtInInterests.sort { a, b in
        a.name < b.name
    }
    builtInInterests.removeAll { interest in
        return interest.name == "__reserved"
    }
    log("Loaded interests.")
    // Store the average length of stored words
    for interest in builtInInterests {
        for word in interest.words {
            wordCount += 1
            characterCount += word.count
        }
    }
    interestWordAverage = Double(characterCount) / Double(wordCount)
    log("Average length of stored interest words: \(interestWordAverage).")
}

func loadLanguages() {
    if let path = Bundle.main.path(forResource: "Languages", ofType: "txt"), let contents = try? String(contentsOfFile: path, encoding: .utf8) {
        log("Loading languages.")
        builtInLanguages = contents.components(separatedBy: .newlines)
        builtInLanguages.sort()
        log("\(builtInLanguages.count) languages loaded.")
    } else {
        log("Could not load languages.")
    }
}

func loadWords() {
    if let path = Bundle.main.path(forResource: "Wordlist", ofType: "txt"), let contents = try? String(contentsOfFile: path, encoding: .utf8) {
        log("Loading words.")
        builtInWords = contents.components(separatedBy: .newlines)
        builtInWords = builtInWords.filter({ word in
            return word.count >= 3
        })
        log("\(builtInWords.count) words loaded.")
    } else {
        log("Could not load words.")
    }
}

func loadLeetlist() {
    if let path = Bundle.main.path(forResource: "Leetlist", ofType: "plist") {
        log("Loading leet list.")
        for (key, value) in NSDictionary(contentsOfFile: path)! {
            builtInLeetList[key as! String] = (value as! String)
        }
        log("\(builtInLeetList.count) leet characters loaded.")
    } else {
        log("Could not load leet property list.")
    }
}

func loadRunningSequences() {
    if let path = Bundle.main.path(forResource: "RunningSequences", ofType: "plist"), let array = NSArray(contentsOfFile: path) as? [String] {
        log("Loading running sequences.")
        builtInRunningSequences = array
        log("\(builtInRunningSequences.count) running sequences loaded.")
    } else {
        log("Could not load running sequences property list.")
    }
}

func loadAPIKeys() {
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
