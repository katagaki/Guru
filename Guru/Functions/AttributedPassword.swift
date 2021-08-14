//
//  AttributedPassword.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/08/14.
//

import UIKit

func attributedPassword(_ password: String) -> NSAttributedString {
    let charactersInPassword = Array(password)
    let attributedText = NSMutableAttributedString(string: password)
    
    for i in 0..<charactersInPassword.count {
        let char: Character = charactersInPassword[i]
        let range: NSRange = NSRange(location: i, length: 1)
        switch true {
        case char.isUppercase:
            let font: UIFont = UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont(name: "Menlo", size: 16.0)!)
            let color: UIColor = .systemIndigo
            attributedText.addAttribute(NSAttributedString.Key.font, value: font, range: range)
            attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        case char.isLowercase:
            let font: UIFont = UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont(name: "Menlo", size: 16.0)!)
            let color: UIColor = .systemBlue
            attributedText.addAttribute(NSAttributedString.Key.font, value: font, range: range)
            attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        case char.isNumber:
            let font: UIFont = UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont(name: "Menlo", size: 16.0)!)
            let color: UIColor = .systemRed
            attributedText.addAttribute(NSAttributedString.Key.font, value: font, range: range)
            attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        default:
            let font: UIFont = UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont(name: "Menlo", size: 16.0)!)
            let color: UIColor = .systemOrange
            attributedText.addAttribute(NSAttributedString.Key.font, value: font, range: range)
            attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        }
    }
    
    return attributedText
    
}
