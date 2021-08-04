//
//  PasswordQuestionnaireViewController.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/23.
//

import UIKit

class PasswordQuestionnaireViewController: OnboardingViewController {
    
    @IBOutlet weak var skipButton: UIButton!
    
    // MARK: Interface Builder
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Localization
        
        navigationItem.title = NSLocalizedString("PasswordQuestionnaireTitle", comment: "Onboarding")
        
        contentLabel.text = NSLocalizedString("PasswordQuestionnaireText", comment: "Onboarding")
        
        skipButton.setTitle(NSLocalizedString("SkipPasswordQuestionnaire", comment: "Onboarding"), for: .normal)
        
        primaryButton.setTitle(NSLocalizedString("Continue", comment: "General"), for: .normal)
        
    }
    
}
