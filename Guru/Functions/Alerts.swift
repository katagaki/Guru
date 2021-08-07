//
//  Alerts.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/28.
//

import UIKit

public func showInputAlert(title: String,
                           message: String,
                           textType: UITextContentType,
                           keyboardType: UIKeyboardType,
                           capitalizationType: UITextAutocapitalizationType,
                           placeholder: String,
                           defaultText: String,
                           _ sender: Any,
                           completion: @escaping (String?) -> Void) {
    let alert = UIAlertController(title: title,
                                  message: message,
                                  preferredStyle: .alert)
    alert.addTextField { textField in
        textField.placeholder = placeholder
        textField.text = defaultText
        textField.textContentType = textType
        textField.keyboardType = keyboardType
        textField.autocapitalizationType = capitalizationType
    }
    alert.addAction(UIAlertAction(title: NSLocalizedString("Continue", comment: "General"),
                                  style: .default,
                                  handler: { _ in
        log("Got alert response.")
        completion((alert.textFields![0].text == "" ? nil : alert.textFields![0].text) ?? nil)
    }))
    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "General"),
                                  style: .cancel,
                                  handler: { _ in
        log("Alert cancelled by user.")
        completion(nil)
    }))
    (sender as! UIViewController).present(alert, animated: true, completion: nil)
}

public func featureUnavailableAlert(_ sender: Any) {
    let featureUnavailableAlert = UIAlertController(title: NSLocalizedString("FeatureUnavailableTitle", comment: "General"),
                                           message: NSLocalizedString("FeatureUnavailableText", comment: "General"),
                                           preferredStyle: .alert)
    featureUnavailableAlert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "General"),
                                           style: .default,
                                           handler: nil))
    (sender as! UIViewController).present(featureUnavailableAlert, animated: true, completion: nil)
}
