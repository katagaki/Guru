//
//  AuthenticationViewController.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/05/23.
//

import LocalAuthentication
import UIKit

class AuthenticationViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var lockIconView: ExtendedImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var unlockButton: UIButton!
    
    weak var contentLockableDelegate: ContentLockable? = nil
    var unlockImmediately: Bool = true
    
    var activeField: UITextField?
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        isModalInPresentation = true
        titleLabel.text = NSLocalizedString("UnlockGuru", comment: "Authentication")
        if laContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
            if laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                switch laContext.biometryType {
                case .faceID:
                    log("Face ID supported on this device. Configuring view for Face ID.")
                    contentLabel.text = NSLocalizedString("UseFaceIDToUnlock", comment: "Authentication")
                    unlockButton.setImage(UIImage(systemName: "faceid"), for: .normal)
                case .touchID:
                    log("Touch ID supported on this device. Configuring view for Touch ID.")
                    contentLabel.text = NSLocalizedString("UseTouchIDToUnlock", comment: "Authentication")
                    unlockButton.setImage(UIImage(systemName: "touchid"), for: .normal)
                case .none:
                    log("No biometrics supported on this device. Configuring view for passcode.")
                    contentLabel.text = NSLocalizedString("UsePasswordToUnlock", comment: "Authentication")
                    unlockButton.setImage(UIImage(systemName: "key"), for: .normal)
                @unknown default:
                    contentLabel.text = NSLocalizedString("UseBiometricsToUnlock", comment: "Authentication")
                    unlockButton.setImage(UIImage(systemName: "figure.stand"), for: .normal)
                }
            } else {
                log("No biometrics supported on this device. Configuring view for passcode.")
                contentLabel.text = NSLocalizedString("UsePasswordToUnlock", comment: "Authentication")
                unlockButton.setImage(UIImage(systemName: "key"), for: .normal)
            }
            unlockButton.isEnabled = true
        } else {
            log("No passcode set! Disabling unlock.")
            contentLabel.text = NSLocalizedString("SetPasscodeOrBiometrics", comment: "Authentication")
            unlockButton.setImage(UIImage(systemName: "key"), for: .normal)
            unlockButton.isEnabled = false
        }
        
        // Localization
        unlockButton.setTitle(NSLocalizedString("Unlock", comment: "Authentication"), for: .normal)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        log("\(self.className) has appeared.")
        if unlockImmediately {
            unlock(unlockButton!)
        }
    }
    
    // MARK: Interface Builder
    
    @IBAction func unlock(_ sender: Any) {
        unlockButton.isEnabled = false
        log("Unlocking with iOS authentication method now!")
        userProfile = UserProfile()
        if let userProfile = userProfile {
            userProfile.setBiometryType(biometryType: laContext.biometryType)
            userProfile.setSynchronizable(synchronizable: defaults.bool(forKey: "Feature.iCloudSync"))
            userProfile.prepareKeychains()
            if userProfile.open() {
                log("Successful authentication, user profile opened.")
                lockIconView.image = UIImage(systemName: "lock.open.fill")
                contentLockableDelegate?.unlockContent()
                log("Performing analysis on passwords.")
                DispatchQueue.global(qos: .background).async {
                    updatePasswordStatistics()
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            } else {
                log("Authentication failed, no user profile opened.")
                unlockButton.isEnabled = true
                lockIconView.shake()
            }
        }
    }
    
    @IBAction func resetProfile(_ sender: Any) {
        laContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: NSLocalizedString("DeleteProfileAuthentication", comment: "Authentication")) { success, error in
            if success {
                DispatchQueue.main.async {
                    Guru.resetProfile(viewController: self)
                }
            }
        }
    }
    
}
