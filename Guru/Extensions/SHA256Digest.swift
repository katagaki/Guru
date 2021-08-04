//
//  SHA256Digest.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/25.
//

import Foundation
import CryptoKit

extension SHA256Digest {
    
    func string() -> String {
        return self.compactMap { String(format: "%02x", $0) }.joined()
    }
    
}
