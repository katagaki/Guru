//
//  PasswordAnalysis.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/08/01.
//

import Foundation

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
    
    return wordsFound
}

//public func analyzeCharacters(logins: [Login]) -> (freqUppercase, freqLowercase, freqNumbers, freqSymbols) {
//    
//}
