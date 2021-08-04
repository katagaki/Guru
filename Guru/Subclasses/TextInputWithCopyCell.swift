//
//  TextInputWithCopyCell.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/05/23.
//

import UIKit

class TextInputWithCopyCell: UITableViewCell {
    
    @IBOutlet weak var textView: CenteredTextView!
    
    public weak var buttonHandler: HandlesCellButton? = nil
    
    @IBAction func copyPassword(_ sender: Any) {
        if textView.text != "" {
            log("Copying")
            UIPasteboard.general.string = textView.text!
            if buttonHandler != nil {
                buttonHandler!.handleCellButton()
            }
            log("Copied")
        }
    }
    
}
