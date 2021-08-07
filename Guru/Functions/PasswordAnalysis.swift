//
//  PasswordAnalysis.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/08/01.
//

import Foundation

let updatePasswordStatisticsQueue = DispatchQueue(label: "updatePasswordStatistics", attributes: .concurrent)
var averagePasswordLength: Double = 0.0
var freqUppercase: Double = 0
var freqUppercaseCount: Int = 0
var freqLowercase: Double = 0
var freqLowercaseCount: Int = 0
var freqNumbers: Double = 0
var freqNumbersCount: Int = 0
var freqSymbols: Double = 0
var freqSymbolsCount: Int = 0
var totalCharacterCount: Int {
    return freqUppercaseCount + freqLowercaseCount + freqNumbersCount + freqSymbolsCount
}

/// Analyzes a password for words.
/// - Parameter password: The password to analyze.
/// - Returns: An array of words.
public func analyzeForWords(password: String) -> [String] {
    let semaphore = DispatchSemaphore(value: 0)
    let queue = DispatchQueue(label: "analyze", attributes: .concurrent)
    var wordsFound: [String] = []
    let filteredPassword: String = String(password.unicodeScalars.filter { CharacterSet.letters.contains($0) }).lowercased()
    
    DispatchQueue.concurrentPerform(iterations: builtInWords.count) { i in
        if filteredPassword.contains(builtInWords[i]) {
            queue.async(flags: .barrier) {
                wordsFound.append(builtInWords[i])
            }
        }
    }
    
    queue.async(flags: .barrier) {
        semaphore.signal()
    }
    semaphore.wait()
    
    log("""
Password analysis completed.
Words found: \(wordsFound.joined(separator: ","))
""")
    return wordsFound
}

public func updatePasswordStatistics() {
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
    
    if let userProfile = userProfile {
        
        averagePasswordLength = Double(userProfile.logins.reduce(0) { partialResult, login in
            return partialResult + (login.password ?? "").count
        }) / Double(userProfile.logins.count)
        
        log("Analyzing \(userProfile.logins.count) password(s).")
        
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
                    character.isMathSymbol: totalSymbols += 1
                default: break
                }
            }
            
            updatePasswordStatisticsQueue.async(flags: .barrier) {
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
        
        updatePasswordStatisticsQueue.async(flags: .barrier) {
            freqUppercase /= Double(userProfile.logins.count)
            freqLowercase /= Double(userProfile.logins.count)
            freqNumbers /= Double(userProfile.logins.count)
            freqSymbols /= Double(userProfile.logins.count)
            semaphore.signal()
        }
        semaphore.wait()
        
        log("""
Password analysis completed.
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
        log("Password analysis completed. No user profile to analyze.")
    }
}
