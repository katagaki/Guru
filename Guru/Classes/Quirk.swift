//
//  Quirk.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/17.
//

import Foundation

public class Quirk: NSObject {
    public var domain: String?
    public var minLength: Int?
    public var maxLength: Int?
    public var lowercaseRequired: Bool?
    public var uppercaseRequired: Bool?
    public var numbersRequired: Bool?
    public var symbolsRequired: Bool?
    public var includedSymbols: String?
    public var excludedSymbols: String?
    public var maxConsecutive: Int?
    
    public override init() {
        super.init()
    }
    
}
