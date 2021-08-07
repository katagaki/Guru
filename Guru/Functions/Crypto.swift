//
//  Crypto.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/28.
//

import Foundation

// MARK: Cryptographically secure random numbers (cS)

/// Flip a cryptographically sound coin.
/// - Returns: A boolean representing heads/tails.
func cSCoinFlip() -> Bool {
    return cSRandomNumber(from: 0, to: 2) == 1
}

/// Generate a cryptographically sound random number from 0 to the specified upper limit (exclusive).
/// - Parameter to: The upper limit of the random number (exclusive).
/// - Returns: A cryptographically sound random number.
func cSRandomNumber(to: Int) -> Int {
    if to == 0 {
        return 0
    } else {
        return cSRandomNumber() % to
    }
}

/// Generate a cryptographically sound random number from a specified lower limit (inclusive) to the specified upper limit (exclusive).
/// - Parameters:
///   - from: The lower limit of the random number (inclusive).
///   - to: The upper limit of the random number (exclusive).
/// - Returns: A cryptographically sound random number.
func cSRandomNumber(from: Int, to: Int) -> Int {
    let diff = to - from
    if from == to {
        return from
    } else {
        return from + (cSRandomNumber() % diff)
    }
}

/// Generate a cryptographically sound random number.
/// - Returns: A cryptographically sound random number.
func cSRandomNumber() -> Int {
    let bytesCount = 4
    var random: UInt32 = 0
    var randomBytes = [UInt8](repeating: 0, count: bytesCount)
    _ = SecRandomCopyBytes(kSecRandomDefault, bytesCount, &randomBytes)
    NSData(bytes: randomBytes, length: bytesCount).getBytes(&random, length: bytesCount)
    return Int(random)
}
