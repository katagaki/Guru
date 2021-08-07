//
//  WelcomeToGuruViewController.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/06/04.
//

import LocalAuthentication
import SafariServices
import UIKit

class WelcomeToGuruViewController: OnboardingViewController, SFSafariViewControllerDelegate {
        
    @IBOutlet weak var tosButton: StylizedButton!
    @IBOutlet weak var privacyPolicyButton: StylizedButton!
    
    // MARK: Interface Builder
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        isModalInPresentation = true
        
        // Localization
        
        navigationItem.title = NSLocalizedString("WelcomeTitle", comment: "Onboarding")
        
        if laContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
            contentLabel.text = NSLocalizedString("WelcomeText", comment: "Onboarding")
        } else {
            contentLabel.text = NSLocalizedString("WelcomeTextPasscodeRequired", comment: "Onboarding")
            primaryButton.isEnabled = false
        }
        
        tosButton.setTitle(NSLocalizedString("TermsOfService", comment: "General"), for: .normal)
        privacyPolicyButton.setTitle(NSLocalizedString("PrivacyPolicy", comment: "General"), for: .normal)
        primaryButton.setTitle(NSLocalizedString("Continue", comment: "General"), for: .normal)
        
    }
    
    // MARK: Interface Builder
    
    @IBAction func openTOS(_ sender: Any) {
        let safariViewController = SFSafariViewController(url: URL(string: "https://mypwd.guru/terms")!)
        safariViewController.delegate = self
        safariViewController.modalPresentationStyle = .pageSheet
        present(safariViewController, animated: true)
    }
    
    @IBAction func openPrivacyPolicy(_ sender: Any) {
        let safariViewController = SFSafariViewController(url: URL(string: "https://mypwd.guru/privacy")!)
        safariViewController.delegate = self
        safariViewController.modalPresentationStyle = .pageSheet
        present(safariViewController, animated: true)
    }
    
}
