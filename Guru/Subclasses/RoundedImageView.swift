//
//  RoundedImageView.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/05/21.
//

import UIKit

class RoundedImageView: UIImageView {
    
    @IBInspectable var cornerRadius: CGFloat = 7.0 {
        didSet {
            if cornerRadius == 0.0 {
                layer.cornerRadius = frame.height / 2
            } else {
                layer.cornerRadius = cornerRadius
            }
        }
    }
    
    @IBInspectable var borderThickness: CGFloat = 0.25 {
        didSet {
            layer.borderWidth = borderThickness
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor(cgColor: CGColor(gray: 0.65, alpha: 0.5)) {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
}
