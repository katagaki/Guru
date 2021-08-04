//
//  CenteredTextView.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/05/23.
//

import UIKit

class CenteredTextView: UITextView {
    
    override var contentSize: CGSize {
        didSet {
            var topCorrection = (bounds.size.height - contentSize.height * zoomScale) / 2.0
            topCorrection = max(0, topCorrection)
            contentInset = UIEdgeInsets(top: topCorrection, left: -4.0, bottom: 0, right: 0)
        }
    }
    
}
