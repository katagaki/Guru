//
//  String.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/04.
//

import Foundation

extension String {
    
    // Improved Character operations for String
    
    func character(in index: Int) -> Character {
        if index > (Array(self).count - 1) {
            return Character(" ")
        } else {
            return Array(self)[index]
        }
    }
    
    func replacingCharacter(in index: Int, to char: Character) -> String {
        var originalString = Array(self)
        originalString[index] = char
        return String(originalString)
    }
    
    mutating func insertCharacter(_ strChar: String, at index: Int) {
        let index = self.index(self.startIndex, offsetBy: index)
        insert(strChar.character(in: 0), at: index)
    }
    
    // Improved regex for String
    
    func isValidEmail() -> Bool {
        let regex = try! NSRegularExpression(pattern: "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" +
                                             "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
                                             "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" +
                                             "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" +
                                             "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
                                             "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
                                             "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
    
    func firstMatch(for regex: String) -> String {
        return matches(for: regex)[0]
    }
    
    func matches(for regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self,
                                        range: NSRange(self.startIndex..., in: self))
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    func containsNonLatinCharacters() -> Bool {
        return self.range(of: "\\P{Latin}", options: .regularExpression) != nil
    }
}
