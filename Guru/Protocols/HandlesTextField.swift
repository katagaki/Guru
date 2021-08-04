//
//  HandlesTextField.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/22.
//

import UIKit

protocol HandlesTextField: AnyObject {
    func handleTextField()
    func handleTextFieldBeginEditing(_ sender: UITextField)
}
