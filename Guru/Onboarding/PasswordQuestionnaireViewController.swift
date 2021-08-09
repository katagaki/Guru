//
//  PasswordQuestionnaireViewController.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/23.
//

import UIKit

class PasswordQuestionnaireViewController: OnboardingViewController {
    
    @IBOutlet weak var skipButton: UIButton!
    
    var setAQuestions: [String] = []
    var setBQuestions: [String] = []
    var setCQuestions: [String] = []
    
    // MARK: Interface Builder
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Load questions
        for i in 1...10 {
            setAQuestions.append(NSLocalizedString("QuestionnaireQuestionA\(i)", comment: "Onboarding"))
        }
        for i in 1...7 {
            setBQuestions.append(NSLocalizedString("QuestionnaireQuestionB\(i)", comment: "Onboarding"))
        }
        for i in 1...5 {
            setCQuestions.append(NSLocalizedString("QuestionnaireQuestionC\(i)", comment: "Onboarding"))
        }
        
        // Localization
        navigationItem.title = NSLocalizedString("PasswordQuestionnaireTitle", comment: "Onboarding")
        contentLabel.text = NSLocalizedString("PasswordQuestionnaireText", comment: "Onboarding")
        skipButton.setTitle(NSLocalizedString("SkipPasswordQuestionnaire", comment: "Onboarding"), for: .normal)
        primaryButton.setTitle(NSLocalizedString("Continue", comment: "General"), for: .normal)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowQuestions", let destination = segue.destination as? QuestionViewController {
            destination.questions = [setAQuestions.randomElement()!,
                                     setBQuestions.randomElement()!,
                                     setCQuestions.randomElement()!]
        }
    }
    
}
