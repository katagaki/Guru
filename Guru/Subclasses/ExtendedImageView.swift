//
//  ExtendedImageView.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/05/23.
//

import UIKit

class ExtendedImageView: UIImageView {
    
    func shake(count: Float = 3, for duration: TimeInterval = 0.25, withTranslation translation: Float = 10) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.repeatCount = count
        animation.duration = duration/TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        animation.values = [translation, -translation]
        layer.add(animation, forKey: "shake")
    }
    
}
