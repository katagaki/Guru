//
//  PasswordTransformation.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/08/01.
//

import Foundation

public enum PasswordTransformation {
    case AddInterestWords
    case AddPersonalizedWords
    case RandomlyUppercase
    case RandomlyLowercase
    case RandomlyReplaceWithNumbers
    case RandomlyReplaceWithSymbols
    case RandomlyCreateRunningLetters
    case RandomlyCreateRunningNumbers
    case ApplyFrequentlyUsedCharacters
    case ApplyPersonalizedWords
    case Leetify
}
