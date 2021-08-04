//
//  UIView.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/05/28.
//

import UIKit

extension UIView {
    
    func anchorAllEdgesToSuperview() {
        self.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 9.0, *) {
            addSuperviewConstraint(constraint: topAnchor.constraint(equalTo: (superview?.topAnchor)!))
            addSuperviewConstraint(constraint: leftAnchor.constraint(equalTo: (superview?.leftAnchor)!))
            addSuperviewConstraint(constraint: bottomAnchor.constraint(equalTo: (superview?.bottomAnchor)!))
            addSuperviewConstraint(constraint: rightAnchor.constraint(equalTo: (superview?.rightAnchor)!))
        }
        else {
            for attribute : NSLayoutConstraint.Attribute in [.left, .top, .right, .bottom] {
                anchorToSuperview(attribute: attribute)
            }
        }
    }
    
    func anchorToSuperview(attribute: NSLayoutConstraint.Attribute) {
        addSuperviewConstraint(constraint: NSLayoutConstraint(item: self, attribute: attribute, relatedBy: .equal, toItem: superview, attribute: attribute, multiplier: 1.0, constant: 0.0))
    }
    
    func addSuperviewConstraint(constraint: NSLayoutConstraint) {
        superview?.addConstraint(constraint)
    }
    
}
