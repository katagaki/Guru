//
//  ReportsProgress.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/29.
//

import UIKit

protocol ReportsProgress: AnyObject {
    func updateProgress(progress: Double, total: Double)
}
