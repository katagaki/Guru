//
//  PasswordCharacterPolicy.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/25.
//

import Foundation

public enum PasswordCharacterPolicy: String {
    case ContainsLowercase = "abcdefghijklmnopqrstuvwxyz"
    case ContainsUppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    case ContainsNumbers = "0123456789"
    case ContainsBasicSymbols = ".!-#$"
    case ContainsComplexSymbols = "%&^~`:+/\\|<>_"
    case ContainsSQLReserved = "[]{}(),;?*!@=\'\""
    case ContainsSpaces = " "
}
