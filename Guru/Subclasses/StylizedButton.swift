//
//  StylizedButton.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/03.
//

import UIKit

class StylizedButton: UIButton {
    
    // Stylized button for iOS 14 compatibility
    
    @IBInspectable var topContentInsets: CGFloat = 0.0 {
        didSet {
            if #available(iOS 15.0, *) { } else {
                contentEdgeInsets.top = topContentInsets
            }
        }
    }
    
    @IBInspectable var bottomContentInsets: CGFloat = 0.0 {
        didSet {
            if #available(iOS 15.0, *) { } else {
                contentEdgeInsets.bottom = bottomContentInsets
            }
        }
    }
    
    @IBInspectable var titleImagePadding: CGFloat = 0.0 {
        didSet {
            if #available(iOS 15.0, *) { } else {
                titleEdgeInsets.left = titleImagePadding
            }
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            if #available(iOS 15.0, *) { } else {
                clipsToBounds = true
                layer.cornerRadius = cornerRadius
            }
        }
    }
    
    @IBInspectable var buttonFilled: Bool = false {
        didSet {
            if #available(iOS 15.0, *) { } else {
                switch buttonFilled {
                case true:
                    backgroundColor = tintColor
                    tintColor = .white
                case false:
                    backgroundColor = UIColor.clear
                }
            }
        }
    }
    
}
