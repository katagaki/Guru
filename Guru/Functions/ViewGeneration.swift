//
//  ViewGeneration.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/31.
//

import UIKit

public func floatingView(views: [UIView], arrangeAs type: FloatingViewType, margins: Int = 20) -> UIVisualEffectView {
    let floatingView: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
    floatingView.clipsToBounds = true
    floatingView.layer.cornerRadius = 12.0
    floatingView.layer.opacity = 0.0
    for i in 0..<views.count {
        floatingView.contentView.addSubview(views[i])
        views[i].translatesAutoresizingMaskIntoConstraints = false
        switch type {
        case .Horizontal:
            if i == 0 {
                views[i].leftAnchor.constraint(equalTo: floatingView.contentView.leftAnchor, constant: CGFloat(margins)).isActive = true
            }
            if i == (views.count - 1) {
                if i != 0 {
                    views[i].leftAnchor.constraint(equalTo: views[i - 1].rightAnchor, constant: CGFloat(margins / 2)).isActive = true
                }
                views[i].rightAnchor.constraint(equalTo: floatingView.rightAnchor, constant: CGFloat(-margins)).isActive = true
            } else {
                if i != 0 {
                    views[i].leftAnchor.constraint(equalTo: views[i - 1].rightAnchor, constant: CGFloat(margins / 2)).isActive = true
                }
            }
            if views[i] is UIActivityIndicatorView {
                views[i].centerYAnchor.constraint(equalTo: floatingView.contentView.centerYAnchor).isActive = true
            } else {
                views[i].topAnchor.constraint(equalTo: floatingView.contentView.topAnchor, constant: CGFloat(margins)).isActive = true
                views[i].bottomAnchor.constraint(equalTo: floatingView.contentView.bottomAnchor, constant: CGFloat(-margins)).isActive = true
            }
        case .Vertical:
            if i == 0 {
                views[i].topAnchor.constraint(equalTo: floatingView.contentView.topAnchor, constant: CGFloat(margins)).isActive = true
            }
            if i == (views.count - 1) {
                if i != 0 {
                    views[i].topAnchor.constraint(equalTo: views[i - 1].bottomAnchor, constant: CGFloat(margins / 2)).isActive = true
                }
                views[i].bottomAnchor.constraint(equalTo: floatingView.bottomAnchor, constant: CGFloat(-margins)).isActive = true
            } else {
                if i != 0 {
                    views[i].topAnchor.constraint(equalTo: views[i - 1].bottomAnchor, constant: CGFloat(margins / 2)).isActive = true
                }
            }
            if views[i] is UIActivityIndicatorView {
                views[i].centerXAnchor.constraint(equalTo: floatingView.contentView.centerXAnchor).isActive = true
            } else {
                views[i].leftAnchor.constraint(equalTo: floatingView.contentView.leftAnchor, constant: CGFloat(margins)).isActive = true
                views[i].rightAnchor.constraint(equalTo: floatingView.contentView.rightAnchor, constant: CGFloat(-margins)).isActive = true
            }
        }
    }
    return floatingView
}

public func center(view: UIView, in parentView: UIView) {
    parentView.addSubview(view)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.centerXAnchor.constraint(equalTo: parentView.centerXAnchor).isActive = true
    view.centerYAnchor.constraint(equalTo: parentView.centerYAnchor).isActive = true
}

public func float(view: UIView, below topView: UIView, in parentView: UIView, margins: Int = 20) {
    parentView.addSubview(view)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: CGFloat(margins)).isActive = true
    view.leftAnchor.constraint(equalTo: parentView.leftAnchor, constant: CGFloat(margins)).isActive = true
    view.rightAnchor.constraint(equalTo: parentView.rightAnchor, constant: CGFloat(-margins)).isActive = true
}

public func singleLinedLabel(withText text: String) -> UILabel {
    let label: UILabel = UILabel()
    label.text = text
    label.font = UIFont.preferredFont(forTextStyle: .body)
    label.textAlignment = .center
    label.numberOfLines = 1
    return label
}

public func singleLinedMonoLabel(withText text: String) -> UILabel {
    let label: UILabel = UILabel()
    label.text = text
    label.font = UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: UIFont(name: "Menlo", size: 16.0)!)
    label.textAlignment = .center
    label.numberOfLines = 1
    return label
}
