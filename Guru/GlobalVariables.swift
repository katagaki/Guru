//
//  GlobalVariables.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/01.
//

import Foundation
import LocalAuthentication
import UIKit

// MARK: System Features

let defaults = UserDefaults.standard
let notifications = NotificationCenter.default
let files = FileManager.default
let laContext = LAContext()

// MARK: App Global Settings

var isFirstOpenOperationsDone: Bool = false

/// Enable debug options to enable the Delete Profile button on the lock screen.
let isDebugOptionsEnabled = false

// MARK: User Profile

var userProfile: UserProfile?
