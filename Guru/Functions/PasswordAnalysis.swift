//
//  PasswordAnalysis.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/08/01.
//

import Foundation
import Crypto

// Character statistics
var averagePasswordLength: Double = 0.0
var averageUppercaseRatio: Double = 0
var averageLowercaseRatio: Double = 0
var averageNumberRatio: Double = 0
var averageSymbolRatio: Double = 0
var uppercaseCount: Int = 0
var lowercaseCount: Int = 0
var numbersCount: Int = 0
var symbolsCount: Int = 0
var characterFrequency: [Character:Int] = [:]
var symbolFrequency: [Character:Int] = [:]
var totalCharacterCount: Int {
    return uppercaseCount + lowercaseCount + numbersCount + symbolsCount
}

// Linguistic statistics
var wordCountPerPassword: [String:[String:Int]] = [:]
var wordCountCombined: [String:Int] {
    return wordCountPerPassword.map { keyValuePair in
        return keyValuePair.value
    }.reduce(into: [:]) { partialResult, wordCountDictionary in
        for key in wordCountDictionary.keys {
            partialResult.updateValue((partialResult[key] ?? 0) + wordCountDictionary[key]!, forKey: key)
        }
    }
}
var freqWordsConvertedToLeet: Double = 0.0
var averageWordLength: Double = 0.0
var averageLeetLength: Double = 0.0

// Keyboard habit statistics
var runningLetterSequenceCount: Double = 0.0
var runningNumberSequenceCount: Double = 0.0

/// Analyzes all user profile login passwords' word frequencies.
func analyzePasswordWords(progressReporter: ReportsProgress? = nil) {
    let queue = DispatchQueue(label: "analyzePasswordWords", attributes: .concurrent)
    let semaphore = DispatchSemaphore(value: 0)
    
    wordCountPerPassword.removeAll()
    if let wordCountPerPasswordFromUserDefaults = defaults.object(forKey: "Feature.Intelligence.AnalyzedPasswords.Words") {
        wordCountPerPassword = wordCountPerPasswordFromUserDefaults as! [String : [String : Int]]
    }
    let existingAnalyses: [String] = Array(wordCountPerPassword.keys)
    averageWordLength = 0.0
    
    if let userProfile = userProfile {
        if userProfile.logins.count > 0 {
            let filteredWords: [String] = builtInWords.filter { word in
                return word.count >= 4
            }
            var currentCount: Int = 0
            let totalCount: Int = userProfile.logins.count
            
            log("Analyzing \(userProfile.logins.count) password(s)' words.")
            
            DispatchQueue.concurrentPerform(iterations: userProfile.logins.count) { i in
                let queueInner = DispatchQueue(label: "analyzePasswordWords.dispatchQueue", attributes: .concurrent)
                let login: Login = userProfile.logins[i]
                let passwordCharacters: [Character] = Array(login.password ?? "")
                let passwordHash: String = SHA256.hash(data: String(passwordCharacters).data(using: .utf8)!).string().lowercased()
                let lettersInPassword: [Character] = passwordCharacters.filter { character in
                    return character.isLetter
                }
                let passwordWithOnlyLetters: String = String(lettersInPassword).lowercased()
                var analyzedPasswordWordCount: [String:Int] = [:]
                
                if !existingAnalyses.contains(passwordHash) {
                    let wordsInPassword: [String] = filteredWords.filter { word in
                        return passwordWithOnlyLetters.contains(word)
                    }
                    for word in wordsInPassword {
                        queueInner.async(flags: .barrier) {
                            analyzedPasswordWordCount.updateValue((analyzedPasswordWordCount[word] ?? 0) + 1, forKey: word)
                            userProfile.preferredWords.updateValue((userProfile.preferredWords[word] ?? 0) + 1, forKey: word)
                            semaphore.signal()
                        }
                        semaphore.wait()
                    }
                    queue.async(flags: .barrier) {
                        wordCountPerPassword.updateValue(analyzedPasswordWordCount, forKey: passwordHash)
                        defaults.set(wordCountPerPassword, forKey: "Feature.Intelligence.AnalyzedPasswords.Words")
                        log("Stored analysis for password \(i).")
                        currentCount += 1
                        if let progressReporter = progressReporter {
                            progressReporter.updateProgress(progress: Double(currentCount), total: Double(totalCount))
                        }
                    }
                } else {
                    currentCount += 1
                    if let progressReporter = progressReporter {
                        progressReporter.updateProgress(progress: Double(currentCount), total: Double(totalCount))
                    }
                }
                
            }
            
            queue.async(flags: .barrier) {
                let totalWordLength: Int = wordCountCombined.reduce(0, { partialResult, keyValuePair in
                    return partialResult + (keyValuePair.key.count * keyValuePair.value)
                })
                let totalNumberOfWords: Int = wordCountCombined.reduce(0) { partialResult, keyValuePair in
                    return partialResult + keyValuePair.value
                }
                averageWordLength = Double(totalWordLength) / Double(totalNumberOfWords)
                semaphore.signal()
            }
            semaphore.wait()
            
        } else {
            if let progressReporter = progressReporter {
                progressReporter.updateProgress(progress: 1.0, total: 1.0)
            }
            log("Password word analysis completed. No logins to analyze.")
        }
    } else {
        if let progressReporter = progressReporter {
            progressReporter.updateProgress(progress: 1.0, total: 1.0)
        }
        log("Password word analysis completed. No user profile to analyze.")
    }
    
    queue.async(flags: .barrier) {
        semaphore.signal()
    }
    semaphore.wait()
    
    log("Password word analysis completed. \(wordCountPerPassword.count) password(s) analyzed with \(wordCountCombined.count) word(s). Average word length: \(averageWordLength).")
}

/// Analyzes all user profile login passwords' character frequencies and counts.
func analyzePasswordCharacters(progressReporter: ReportsProgress? = nil) {
    let queue = DispatchQueue(label: "updatePasswordStatistics", attributes: .concurrent)
    let semaphore = DispatchSemaphore(value: 0)

    averagePasswordLength = 0.0
    averageUppercaseRatio = 0.0
    uppercaseCount = 0
    averageLowercaseRatio = 0.0
    lowercaseCount = 0
    averageNumberRatio = 0.0
    numbersCount = 0
    averageSymbolRatio = 0.0
    symbolsCount = 0
    characterFrequency.removeAll()
    symbolFrequency.removeAll()
    
    if let userProfile = userProfile {
        if userProfile.logins.count > 0 {
            var currentCount: Int = 0
            let totalCount: Int = userProfile.logins.count

            averagePasswordLength = Double(userProfile.logins.reduce(0) { partialResult, login in
                return partialResult + (login.password ?? "").count
            }) / Double(userProfile.logins.count)
            
            log("Analyzing \(userProfile.logins.count) password(s)' characters.")
            
            DispatchQueue.concurrentPerform(iterations: userProfile.logins.count) { i in
                let login: Login = userProfile.logins[i]
                let passwordCharacters: [Character] = Array(login.password ?? "")
                var totalUppercase: Int = 0
                var totalLowercase: Int = 0
                var totalNumbers: Int = 0
                var totalSymbols: Int = 0
                let totalCharacters: Int = passwordCharacters.count
                            
                for character in passwordCharacters {
                    switch true {
                    case character.isUppercase: totalUppercase += 1
                    case character.isLowercase: totalLowercase += 1
                    case character.isNumber, character.isWholeNumber: totalNumbers += 1
                    case character.isSymbol,
                        character.isPunctuation,
                        character.isWhitespace,
                        character.isCurrencySymbol,
                        character.isMathSymbol:
                        totalSymbols += 1
                        queue.async(flags: .barrier) {
                            symbolFrequency.updateValue((symbolFrequency[character] ?? 0) + 1, forKey: character)
                        }
                    default: break
                    }
                    queue.async(flags: .barrier) {
                        characterFrequency.updateValue((characterFrequency[character] ?? 0) + 1, forKey: character)
                    }
                }
                
                queue.async(flags: .barrier) {
                    averageUppercaseRatio += Double(totalUppercase) / Double(totalCharacters)
                    uppercaseCount += totalUppercase
                    averageLowercaseRatio += Double(totalLowercase) / Double(totalCharacters)
                    lowercaseCount += totalLowercase
                    averageNumberRatio += Double(totalNumbers) / Double(totalCharacters)
                    numbersCount += totalNumbers
                    averageSymbolRatio += Double(totalSymbols) / Double(totalCharacters)
                    symbolsCount += totalSymbols
                    currentCount += 1
                    if let progressReporter = progressReporter {
                        progressReporter.updateProgress(progress: Double(currentCount), total: Double(totalCount))
                    }
                }
            }
            
            queue.async(flags: .barrier) {
                averageUppercaseRatio /= Double(userProfile.logins.count)
                averageLowercaseRatio /= Double(userProfile.logins.count)
                averageNumberRatio /= Double(userProfile.logins.count)
                averageSymbolRatio /= Double(userProfile.logins.count)
                semaphore.signal()
            }
            semaphore.wait()
            
        } else {
            if let progressReporter = progressReporter {
                progressReporter.updateProgress(progress: 1.0, total: 1.0)
            }
            log("Password character analysis completed. No logins to analyze.")
        }
        
        log("Password character analysis completed. Average length of password: \(averagePasswordLength). Frequency of uppercase letters: \(averageUppercaseRatio). Frequency of lowercase letters: \(averageLowercaseRatio). Frequency of numbers: \(averageNumberRatio). Frequency of symbols: \(averageSymbolRatio). Number of uppercase letters: \(uppercaseCount). Number of lowercase letters: \(lowercaseCount). Number of numbers: \(numbersCount). Number of symbols: \(symbolsCount). Total number of characters: \(totalCharacterCount).")
        
    } else {
        if let progressReporter = progressReporter {
            progressReporter.updateProgress(progress: 1.0, total: 1.0)
        }
        log("Password character analysis completed. No user profile to analyze.")
    }
}
