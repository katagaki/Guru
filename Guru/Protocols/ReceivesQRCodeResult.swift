//
//  ReceivesQRCodeResult.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/01.
//

import Foundation

protocol ReceivesQRCodeResult: AnyObject {
    func receiveQRCode(result value: String)
}
