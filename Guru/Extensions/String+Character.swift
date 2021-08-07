//
//  String+Character.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/04.
//

import Foundation

extension String {
    
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
    
}
