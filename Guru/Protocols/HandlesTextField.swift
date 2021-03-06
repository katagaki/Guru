//
//  HandlesTextField.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/22.
//

import UIKit

protocol HandlesTextField: AnyObject {
    func handleTextFieldShouldReturn()
    func handleTextFieldBeginEditing(_ sender: UITextField)
    func handleTextFieldEditingChanged(text: String, sender: Any)
}
