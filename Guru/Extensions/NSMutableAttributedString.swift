//
//  NSMutableAttributedString.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/04.
//

import Foundation

extension NSMutableAttributedString {
    
    public func setAsLink(textToFind:String, linkURL:String) {
        
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(.link, value: linkURL, range: foundRange)
        }
    }
}
