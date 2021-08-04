//
//  HandlesCellSliderValueChange.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/28.
//

import UIKit

protocol HandlesCellSliderValueChange: AnyObject {
    func handleCellValueChange(value: Int, label: UILabel)
}
