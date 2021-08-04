//
//  ContentLockDelegate.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/06/04.
//

import Foundation

protocol ContentLockable: AnyObject {
    func lockContent(animated: Bool, useAutoUnlock: Bool)
    func unlockContent()
}
