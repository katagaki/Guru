//
//  TextInputCell.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/06/30.
//

import UIKit

class TextInputCell: UITableViewCell, UITextFieldDelegate {
    
    weak var textFieldHandler: HandlesTextField? = nil
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    // MARK: Interface Builder
    
    @IBAction func textChanged(_ sender: Any) {
        textFieldHandler?.handleTextFieldEditingChanged(text: textField.text!, sender: self)
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
