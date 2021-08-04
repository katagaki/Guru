//
//  DetailWithCopyCell.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/05/28.
//

import UIKit

class DetailWithCopyCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    public weak var buttonHandler: HandlesCellButton? = nil
    
    @IBAction func copyPassword(_ sender: Any) {
        if contentLabel.text != "" {
            log("Copying")
            UIPasteboard.general.string = contentLabel.text
            if buttonHandler != nil {
                buttonHandler!.handleCellButton()
            }
            log("Copied")
        }
    }
    
}
