//
//  InformationAboutYouViewController.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/06/12.
//

import UIKit

class InformationAboutYouViewController: OnboardingViewController {
        
    // MARK: UIViewController
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if userProfile == nil {
            if laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                userProfile = UserProfile(usesBiometryType: laContext.biometryType, syncsWithiCloud: defaults.bool(forKey: "Feature.iCloudSync"))
            } else {
                userProfile = UserProfile(usesBiometryType: .none, syncsWithiCloud: defaults.bool(forKey: "Feature.iCloudSync"))
            }
        }
        
        if let userProfile = userProfile {
            if !defaults.bool(forKey: "Onboarding.UserProfileCreated") {
                userProfile.new()
                defaults.set(true, forKey: "Onboarding.UserProfileCreated")
            } else {
                if userProfile.open() {
                    log("Existing user profile opened from onboarding.")
                } else {
                    log("Unable to open existing user profile from onboarding.")
                }
            }
        }
        
        // Localization
        
        navigationItem.title = NSLocalizedString("InformationAboutYouTitle", comment: "Onboarding")
        contentLabel.text = NSLocalizedString("InformationAboutYouText", comment: "Onboarding")
        
        primaryButton.setTitle(NSLocalizedString("Continue", comment: "General"), for: .normal)
        
    }
    
}
