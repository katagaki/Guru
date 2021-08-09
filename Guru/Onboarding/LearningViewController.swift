//
//  LearningViewController.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/06/13.
//

import UIKit

class LearningViewController: UIViewController {
    
    @IBOutlet weak var contentLabel: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Localization
        navigationItem.title = NSLocalizedString("LearningTitle", comment: "Onboarding")
        contentLabel.text = NSLocalizedString("LearningText", comment: "Onboarding")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let userProfile = userProfile {
            analyzePasswordWords(progressReporter: nil)
            userProfile.logins.removeAll()
            userProfile.save()
        }
        performSegue(withIdentifier: "ShowAllSet", sender: self)
    }
    
}
