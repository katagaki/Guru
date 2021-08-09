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
        
        // Set up new user profile
        if userProfile == nil {
            if laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                userProfile = UserProfile(usesBiometryType: laContext.biometryType, syncsWithiCloud: defaults.bool(forKey: "Feature.iCloudSync"))
            } else {
                userProfile = UserProfile(usesBiometryType: .none, syncsWithiCloud: defaults.bool(forKey: "Feature.iCloudSync"))
            }
        }
        
        if let userProfile = userProfile {
            userProfile.new()
        }
        
        // Localization
        navigationItem.title = NSLocalizedString("InformationAboutYouTitle", comment: "Onboarding")
        contentLabel.text = NSLocalizedString("InformationAboutYouText", comment: "Onboarding")
        primaryButton.setTitle(NSLocalizedString("Continue", comment: "General"), for: .normal)
        
    }
    
}
