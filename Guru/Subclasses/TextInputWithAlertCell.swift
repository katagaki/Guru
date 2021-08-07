//
//  TextInputWithAlertCell.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/08/07.
//

import UIKit

class TextInputWithAlertCell: UITableViewCell, UITextFieldDelegate {
    
    let queue = DispatchQueue(label: "TextInputWithAlertCell", attributes: .concurrent)

    weak var textFieldHandler: HandlesTextField? = nil
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var alertButton: UIButton!
    
    // MARK: Interface Builder
    
    @IBAction func textChanged(_ sender: Any) {
        if textField.text! != "" {
            checkBreaches(password: textField.text!) { breached, hasError in
                if !hasError, let breached = breached {
                    self.queue.async(flags: .barrier) {
                        DispatchQueue.main.async {
                            self.alertButton.isHidden = !breached
                        }
                    }
                }
            }
        } else {
            alertButton.isHidden = true
        }
    }
    
    @IBAction func alertButtonTapped(_ sender: Any) {
        log("Breached Password button tapped.")
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textFieldHandler?.handleTextFieldBeginEditing(textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFieldHandler?.handleTextFieldShouldReturn()
        return true
    }
    
}
