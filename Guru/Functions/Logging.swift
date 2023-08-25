//
//  Logging.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/28.
//

import Foundation
import os

let loggingQueue = DispatchQueue(label: "log", attributes: .concurrent)
let versionNumber: String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "Dev"
let buildNumber: String = Bundle.main.infoDictionary!["CFBundleVersion"] as? String ?? "Dev"
var appLogs: String = "Guru Version \(versionNumber) Build \(buildNumber) (\(Locale.current.language.languageCode?.identifier ?? "dev"))"

/// Passes a string to the app log, and console.
/// - Parameter text: The text to append to the log.
public func log(_ text: String) {
    let dateString = String(Date().timeIntervalSince1970).components(separatedBy: ".")[0]
    os_log("%s", log: .default, type: .info, text)
    loggingQueue.async(flags: .barrier) {
        appLogs.append(contentsOf: "\n[\(dateString)] \(text)")
    }
}
