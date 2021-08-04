//
//  ParseOTP.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/29.
//

import Foundation

func parseOTP(code: String) -> String {
    var parsedCode: String = code
    if parsedCode.lowercased().starts(with: "otpauth://") {
        parsedCode = parsedCode.firstMatch(for: "secret=.+?&").replacingOccurrences(of: "secret=", with: "").replacingOccurrences(of: "&", with: "").uppercased()
    }
    parsedCode = parsedCode.replacingOccurrences(of: " ", with: "")
    return parsedCode
}
