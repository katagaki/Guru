//
//  UserProfile+CSV.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/08/07.
//

import Foundation

extension UserProfile {
    
    func csv(ofType type: CSVType) -> String {
        
        var csvContents: String = ""
        var dataPoints: [String] = []
        
        log("Starting to create \(type) CSV.")
        
        // Set the header for the CSV
        switch type {
        case .Guru:
            csvContents = "Name,LoginURL,ResetURL,Username,Password,OTPSecret"
        case .Chromium:
            csvContents = "Name,Url,Username,Password"
        case .Safari:
            csvContents = "Title,Url,Username,Password,OTPAuth"
        case .OnePassword:
            csvContents = "Title,Website,Username,Password"
        case .None: break
        }
        
        // Set the positions of the data
        switch type {
        case .Guru:
            dataPoints.append("accountName")
            dataPoints.append("loginURL")
            dataPoints.append("passwordResetURL")
            dataPoints.append("username")
            dataPoints.append("password")
            dataPoints.append("totpSecret")
        case .Chromium, .OnePassword:
            dataPoints.append("accountName")
            dataPoints.append("domain")
            dataPoints.append("username")
            dataPoints.append("password")
        case .Safari:
            dataPoints.append("accountName")
            dataPoints.append("domain")
            dataPoints.append("username")
            dataPoints.append("password")
            dataPoints.append("totpSecret")
        case .None: break
        }
        
        // Enumeratre through logins and add data
        for login in logins {
            csvContents += "\n"
            for dataPoint in dataPoints {
                var dataPointText: String = ""
                switch dataPoint {
                case "accountName": dataPointText = login.accountName ?? ""
                case "loginURL": dataPointText = login.loginURL ?? ""
                case "passwordResetURL": dataPointText = login.passwordResetURL ?? ""
                case "username": dataPointText = login.username ?? ""
                case "password": dataPointText = login.password ?? ""
                case "totpSecret": dataPointText = login.totpSecret ?? ""
                case "domain":
                    if let loginURL = login.loginURL, loginURL != "" {
                        var url = loginURL
                        if !url.starts(with: "https://") && !url.starts(with: "http://") {
                            url = "https://\(url)"
                        }
                        if let url = URL(string: url) {
                            dataPointText = url.host ?? ""
                        }
                    }
                default: log("Unsupported data point: \(dataPoint)")
                }
                // Handle delimiters
                if dataPointText.contains("\"") || dataPointText.contains(",") {
                    dataPointText = dataPointText.replacingOccurrences(of: "\"", with: "\"\"")
                    dataPointText = "\"\(dataPointText)\""
                }
                // Add the data point
                csvContents += dataPointText
                // Add comma if not last item
                if dataPoints.last != dataPoint {
                    csvContents += ","
                }
            }
        }
        
        log("CSV generated successfully.")
        log(csvContents)
        
        return csvContents
    }
    
    func addLogins(fromCSV contents: String, progressReporter: ReportsProgress? = nil) -> (success: Bool, notImportedCount: Int) {
        
        let queue = DispatchQueue(label: "UserProfile.addLogins", attributes: .concurrent)
        let csvByLines: [String] = contents.components(separatedBy: .newlines)
        var csvType: CSVType = .None
        var dataPoints: [String] = []
        var notImportedCount: Int = 0
        var progress: Int = 0
        
        log("Starting to load CSV.")
        
        // Set the header for the CSV
        switch csvByLines[0].lowercased() {
        case "name,loginurl,reseturl,username,password,otpsecret":
            csvType = .Guru
        case "name,url,username,password":
            csvType = .Chromium
        case "title,url,username,password,otpauth":
            csvType = .Safari
        case "title,website,username,password":
            csvType = .OnePassword
        default:
            csvType = .None
            return (false, csvByLines.count - 1)
        }
        
        // Set the positions of the data
        switch csvType {
        case .Guru:
            dataPoints.append("accountName")
            dataPoints.append("loginURL")
            dataPoints.append("passwordResetURL")
            dataPoints.append("username")
            dataPoints.append("password")
            dataPoints.append("totpSecret")
        case .Chromium, .OnePassword:
            dataPoints.append("accountName")
            dataPoints.append("domain")
            dataPoints.append("username")
            dataPoints.append("password")
        case .Safari:
            dataPoints.append("accountName")
            dataPoints.append("domain")
            dataPoints.append("username")
            dataPoints.append("password")
            dataPoints.append("totpSecret")
        case .None: break
        }
        
        // Parse CSV line
        DispatchQueue.concurrentPerform(iterations: csvByLines.count - 1) { i in
            let semaphore = DispatchSemaphore(value: 0)
            
            // Parse CSV
            let splitLines: [String] = csvByLines[i + 1].components(separatedBy: ",")
            var currentIndex: Int = 0
            var currentString: String = ""
            var lastStringHadStartAnchor: Bool = false
            var willAddDataPoint: Bool = false
            let login = Login()
            
            if splitLines.count < dataPoints.count {
                
            } else {
                for splitString in splitLines {
                    if lastStringHadStartAnchor, splitString.hasSuffix("\"") {
                        currentString += "," + String(splitString.dropLast())
                        lastStringHadStartAnchor = false
                        willAddDataPoint = true
                    } else if lastStringHadStartAnchor, !splitString.hasSuffix("\"") {
                        currentString += "," + splitString
                    } else if !lastStringHadStartAnchor, splitString.hasPrefix("\"") {
                        currentString = String(splitString.dropFirst())
                        currentString = currentString.replacingOccurrences(of: "\"\"", with: "\"")
                        lastStringHadStartAnchor = true
                    } else if !lastStringHadStartAnchor, !splitString.hasPrefix("\"") {
                        currentString = splitString
                        currentString = currentString.replacingOccurrences(of: "\"\"", with: "\"")
                        lastStringHadStartAnchor = false
                        willAddDataPoint = true
                    }
                    if willAddDataPoint {
                        let dataPointText: String = dataPoints[currentIndex]
                        switch dataPointText {
                        case "accountName":
                            switch csvType {
                            case .Guru, .Chromium, .OnePassword:
                                login.accountName = currentString
                            case .Safari:
                                login.accountName = currentString.components(separatedBy: " ")[0]
                            case .None: break
                            }
                        case "loginURL": login.loginURL = (currentString == "" ? nil : currentString)
                        case "domain": login.loginURL = (currentString == "" ? nil : currentString)
                        case "passwordResetURL": login.passwordResetURL = (currentString == "" ? nil : currentString)
                        case "username": login.username = (currentString == "" ? nil : currentString)
                        case "password": login.password = currentString
                        case "totpSecret": login.totpSecret = (currentString == "" ? nil : parseOTP(code: currentString))
                        default: log("Unsupported data point: \(dataPointText)")
                        }
                        currentString = ""
                        currentIndex += 1
                        willAddDataPoint = false
                    }
                }
                
                if !logins.contains(where: { existingLogin in
                    return existingLogin.accountName == login.accountName
                }) {
                    // Set login icon
                    login.setAccountIcon {
                        semaphore.signal()
                    }
                    semaphore.wait()
                    
                    // Add login
                    queue.async(flags: .barrier) {
                        if !self.logins.contains(where: { existingLogin in
                            return existingLogin.accountName == login.accountName
                        }) {
                            self.add(login: login)
                        } else {
                            notImportedCount += 1
                            log("Login already exists, will not replace.")
                        }
                    }
                } else {
                    notImportedCount += 1
                    log("Login already exists, will not replace.")
                }
                queue.sync(flags: .barrier) {
                    log("Finished processing login at index \(i).")
                    // Report progress
                    if let progressReporter = progressReporter {
                        progress += 1
                        progressReporter.updateProgress(progress: Double(progress), total: Double(csvByLines.count - 1))
                    }
                }
            }
            
        }
        
        return (true, notImportedCount)
    }
    
}
