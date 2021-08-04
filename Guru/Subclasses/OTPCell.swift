//
//  OTPCell.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/05/28.
//

import UIKit

class OTPCell: UITableViewCell {
    
    @IBOutlet weak var otpLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    public weak var buttonHandler: HandlesCellButton? = nil

    @IBAction func copyPassword(_ sender: Any) {
        log("Copying")
        UIPasteboard.general.string = otpLabel.text?.replacingOccurrences(of: " ", with: "")
        if buttonHandler != nil {
            buttonHandler!.handleCellButton()
        }
        log("Copied")
    }
    
    public func setProgress(time: Int) {
        progressView.progress = Float(Float(time) / 30.0)
        if time <= 5 {
            progressView.tintColor = .systemRed
        } else {
            progressView.tintColor = UIColor(named: "AccentColor")
        }
    }
    
}
