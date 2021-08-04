//
//  Pwnage.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/04.
//

import Foundation

public class Pwnage: NSObject, Decodable {
    public var Name: String?
    public var Title: String?
    public var Domain: String?
    public var BreachDate: Date?
    public var PwnCount: Int?
    public var Description: String?
    public var DataClasses: [String]?
    
    public override init() {
        super.init()
    }
    
    public override var description: String {
        return Name!
    }
    
}
