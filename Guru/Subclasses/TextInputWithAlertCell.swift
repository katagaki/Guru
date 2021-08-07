//
//  TextInputWithAlertCell.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/08/07.
//

import UIKit

class TextInputWithAlertCell: TextInputCell {
    
    let queue = DispatchQueue(label: "TextInputWithAlertCell", attributes: .concurrent)
    
    @IBOutlet weak var alertButton: UIButton!
    
    // MARK: Interface Builder
    
    @IBAction override func textChanged(_ sender: Any) {
        super.textChanged(sender)
        if defaults.bool(forKey: "Feature.BreachDetection.Password") && textField.text! != "" {
            checkBreaches(password: textField.text!) { breached, hasError in
                if !hasError, let breached = breached {
                    self.queue.async(flags: .barrier) {
                        DispatchQueue.main.async {
                            self.alertButton.isHidden = !breached
                        }
                    }
                } else {
                    self.alertButton.isHidden = true
                }
            }
        } else {
            alertButton.isHidden = true
        }
    }
    
    @IBAction func alertButtonTapped(_ sender: Any) {
        log("Breached Password button tapped.")
    }
    
}
