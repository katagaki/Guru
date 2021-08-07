//
//  PasswordAnalysis.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/08/01.
//

import Foundation

// Character statistics
var averagePasswordLength: Double = 0.0
var freqUppercase: Double = 0
var freqUppercaseCount: Int = 0
var freqLowercase: Double = 0
var freqLowercaseCount: Int = 0
var freqNumbers: Double = 0
var freqNumbersCount: Int = 0
var freqSymbols: Double = 0
var freqSymbolsCount: Int = 0
var characterCount: [Character:Int] = [:]
var symbolCount: [Character:Int] = [:]
var totalCharacterCount: Int {
    return freqUppercaseCount + freqLowercaseCount + freqNumbersCount + freqSymbolsCount
}

// Linguistic statistics
var wordCount: [String:Int] = [:]
var freqWordsConvertedToLeet: Double = 0.0
var averageWordLength: Double = 0.0
var averageLeetLength: Double = 0.0

// Keyboard habit statistics
var runningLetterSequenceCount: Double = 0.0
var runningNumberSequenceCount: Double = 0.0

/// Analyzes all user profile login passwords' word frequencies.
public func analyzePasswordWords() {
    let queue = DispatchQueue(label: "analyzePasswordWords", attributes: .concurrent)
    let semaphore = DispatchSemaphore(value: 0)
    
    wordCount.removeAll()
    averageWordLength = 0.0
    
    if let userProfile = userProfile {
        if userProfile.logins.count > 0 {
            
            DispatchQueue.concurrentPerform(iterations: userProfile.logins.count) { i in
                let login: Login = userProfile.logins[i]
                let passwordCharacters: [Character] = Array(login.password ?? "")
                let lettersInPassword: [Character] = passwordCharacters.filter { character in
                    return character.isLetter
                }
                let passwordWithOnlyLetters: String = String(lettersInPassword).lowercased()
                
                DispatchQueue.concurrentPerform(iterations: builtInWords.count) { i in
                    if passwordWithOnlyLetters.contains(builtInWords[i]) {
                        queue.async(flags: .barrier) {
                            wordCount.updateValue((wordCount[builtInWords[i]] ?? 0) + 1, forKey: builtInWords[i])
                        }
                    }
                }
            }
        } else {
            log("Password word analysis completed. No logins to analyze.")
        }
    } else {
        log("Password word analysis completed. No user profile to analyze.")
    }
    
    queue.async(flags: .barrier) {
        semaphore.signal()
    }
    semaphore.wait()
    
    log("""
Password word analysis completed.
Words found: \(wordCount)
""")
}

/// Analyzes all user profile login passwords' character frequencies and counts.
public func analyzePasswordCharacters() {
    let queue = DispatchQueue(label: "updatePasswordStatistics", attributes: .concurrent)
    let semaphore = DispatchSemaphore(value: 0)

    averagePasswordLength = 0.0
    freqUppercase = 0.0
    freqUppercaseCount = 0
    freqLowercase = 0.0
    freqLowercaseCount = 0
    freqNumbers = 0.0
    freqNumbersCount = 0
    freqSymbols = 0.0
    freqSymbolsCount = 0
    characterCount.removeAll()
    symbolCount.removeAll()
    
    if let userProfile = userProfile {
        if userProfile.logins.count > 0 {
                
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
                    case character.isNumber: totalNumbers += 1
                    case character.isSymbol,
                        character.isPunctuation,
                        character.isWhitespace,
                        character.isCurrencySymbol,
                        character.isMathSymbol:
                        totalSymbols += 1
                        symbolCount.updateValue((symbolCount[character] ?? 0) + 1, forKey: character)
                    default: break
                    }
                    characterCount.updateValue((characterCount[character] ?? 0) + 1, forKey: character)
                }
                
                queue.async(flags: .barrier) {
                    freqUppercase += Double(totalUppercase) / Double(totalCharacters)
                    freqUppercaseCount += totalUppercase
                    freqLowercase += Double(totalLowercase) / Double(totalCharacters)
                    freqLowercaseCount += totalLowercase
                    freqNumbers += Double(totalNumbers) / Double(totalCharacters)
                    freqNumbersCount += totalNumbers
                    freqSymbols += Double(totalSymbols) / Double(totalCharacters)
                    freqSymbolsCount += totalSymbols
                }
            }
            
            queue.async(flags: .barrier) {
                freqUppercase /= Double(userProfile.logins.count)
                freqLowercase /= Double(userProfile.logins.count)
                freqNumbers /= Double(userProfile.logins.count)
                freqSymbols /= Double(userProfile.logins.count)
                semaphore.signal()
            }
            semaphore.wait()
            
        } else {
            log("Password character analysis completed. No logins to analyze.")
        }
        
        log("""
Password character analysis completed.
Average length of password: \(averagePasswordLength)
Frequency of uppercase letters: \(freqUppercase)
Frequency of lowercase letters: \(freqLowercase)
Frequency of numbers: \(freqNumbers)
Frequency of symbols: \(freqSymbols)
Number of uppercase letters: \(freqUppercaseCount)
Number of lowercase letters: \(freqLowercaseCount)
Number of numbers: \(freqNumbersCount)
Number of symbols: \(freqSymbolsCount)
Total number of characters: \(totalCharacterCount)
""")
        
    } else {
        log("Password character analysis completed. No user profile to analyze.")
    }
}
