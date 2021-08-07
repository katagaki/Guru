//
//  AllSetViewController.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/06/13.
//

import UIKit

class AllSetViewController: OnboardingViewController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Localization
        navigationItem.title = NSLocalizedString("OnboardingCompletionTitle", comment: "Onboarding")
        contentLabel.text = NSLocalizedString("OnboardingCompletionText", comment: "Onboarding")
        primaryButton.setTitle(NSLocalizedString("OnboardingCompletionButton", comment: "Onboarding"), for: .normal)
        
    }
    
    @IBAction func start(_ sender: Any) {
        dismiss(animated: true) {
            if let parentNavigationController = self.parent as? OnboardingNavigationController {
                parentNavigationController.finishesOnboardingDelegate?.finishOnboarding()
            }
        }
    }
    
}
