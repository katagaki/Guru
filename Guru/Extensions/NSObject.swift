//
//  NSObject.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/29.
//

import Foundation

extension NSObject {
    var className: String {
        return NSStringFromClass(type(of: self)).replacingOccurrences(of: "Guru.", with: "")
    }
}
