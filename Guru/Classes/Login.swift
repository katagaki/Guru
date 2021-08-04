//
//  Login.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/06/03.
//

import FaviconFinder
import Foundation
import UIKit

public class Login: NSObject, Codable {
    
    public var accountName: String?
    private var _accountIcon: String?
    public var username: String?
    public var password: String?
    public var totpSecret: String?
    public var loginURL: String?
    public var passwordResetURL: String?
    
    public override init() {
        super.init()
    }
    
    public func setAccountIcon(newIcon: UIImage) {
        _accountIcon = convertImageToBase64(image: newIcon)
    }
    
    public func setAccountIcon(completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .background).async {
            
            var keywords: [String: String] = [:]
            
            var url: String = self.loginURL ?? ""
            var willUsePredefinedIcon: Bool = false
            
            // Load keyword list for automatic icon selection
            if let plistFile = Bundle.main.path(forResource: "Keywords", ofType: "plist"), let dict = NSDictionary(contentsOfFile: plistFile) {
                for (key, value) in dict {
                    keywords.updateValue(value as! String, forKey: key as! String)
                }
            }
            
            // Add HTTPS to URL
            if !url.starts(with: "https://") && !url.starts(with: "http://") {
                url = "https://\(url)"
            }
            
            // Use predefined service icon for certain URLs
            for (key, value) in keywords {
                if url.contains(key) {
                    log("Using predefined icon for \(key) found in URL: \(value).")
                    self.setAccountIcon(newIcon: UIImage(named: value)!)
                    willUsePredefinedIcon = true
                }
            }
            
            // Get favicon and set it, if not use generic icon
            if !willUsePredefinedIcon, let url = URL(string: url) {
                FaviconFinder(url: url, preferredType: .html, preferences: [.html: FaviconType.appleTouchIcon.rawValue, .ico: "favicon.ico"]).downloadFavicon { result in
                    switch result {
                    case .success(let favicon):
                        log("Favicon downloaded: \(favicon.url).")
                        self.setAccountIcon(newIcon: favicon.image)
                    case .failure(let error):
                        log("Error downloading favicon: \(error). Reverting to generic icon.")
                        self.setAccountIcon(newIcon: UIImage(named: "AI.001")!)
                    }
                    completion()
                }
            } else {
                completion()
            }
        }
    }
    
    public func accountIcon() -> UIImage? {
        if let imageString = _accountIcon {
            return convertBase64ToImage(imageString: imageString)
        } else {
            return nil
        }
    }
    
    private func convertImageToBase64(image: UIImage) -> String {
        let imageData = image.pngData()!
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
    
    private func convertBase64ToImage(imageString: String) -> UIImage {
        let imageData = Data(base64Encoded: imageString,
                             options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
        return UIImage(data: imageData)!
    }
    
    public override var description: String {
        return """
        --- Login Object Descriptor ---
        Account Name: \(accountName ?? "")
        Username: \(username ?? "")
        Password: \(password != nil ? "<redacted>" : "")
        TOTP Secret: \(totpSecret != nil ? "<redacted>" : "")
        Login URL: \(loginURL ?? "")
        Password Reset URL: \(passwordResetURL ?? "")
        """
    }
    
}
