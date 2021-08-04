//
//  Digest.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/07.
//

import CryptoKit
import Foundation

extension Digest {
    var bytes: [UInt8] { Array(makeIterator()) }
    var data: Data { Data(bytes) }
    
    var hex: String {
        bytes.map { String(format: "%02X", $0) }.joined()
    }
}
