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
public func analyze(password: String) -> [String] {
    let queue = DispatchQueue(label: "analyze", attributes: .concurrent)
    var wordsFound: [String] = []
    let filteredPassword: String = String(password.unicodeScalars.filter { CharacterSet.letters.contains($0) }).lowercased()
    
    DispatchQueue.concurrentPerform(iterations: words.count) { i in
        if filteredPassword.contains(words[i]) {
            queue.async(flags: .barrier) {
                wordsFound.append(words[i])
            }
        }
    }
    return wordsFound
}
