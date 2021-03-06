//
//  QuestionViewController.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/06/12.
//

import UIKit

class QuestionViewController: OnboardingViewController {
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var skipButton: UIBarButtonItem!
    
    var activeField: UITextField?
    
    let login: Login = Login()
    var questions: [String] = []
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Set temporary login name
        var accountName: String = "onboarding_\(cSRandomNumber(from: 10000000, to: 99999999))"
        if let userProfile = userProfile {
            repeat {
                accountName = "onboarding_\(cSRandomNumber(from: 10000000, to: 99999999))"
            } while (userProfile.login(withName: accountName) != nil)
        }
        login.accountName = accountName
        
        contentLabel.text = questions.first!
        
        // Localization
        navigationItem.title = NSLocalizedString("QuestionnaireTitle", comment: "Personalization").replacingOccurrences(of: "@$", with: String(4 - questions.count))
        passwordTextField.placeholder = NSLocalizedString("QuestionnaireTextFieldPlaceholder", comment: "Onboarding")
        skipButton.title = NSLocalizedString("Skip", comment: "General")
        primaryButton.setTitle(NSLocalizedString("Continue", comment: "General"), for: .normal)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerForKeyboardNotifications()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowNextQuestion" {
            if let userProfile = userProfile {
                log("Saving questionnaire answer for \(navigationItem.title!).")
                login.password = passwordTextField.text!
                userProfile.remove(login: login.accountName!)
                userProfile.add(login: login)
            }
        }
        if let destination = segue.destination as? QuestionViewController {
            destination.questions = Array(questions.dropFirst())
        }
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        deregisterFromKeyboardNotifications()
        super.dismiss(animated: flag, completion: completion)
    }
    
    // MARK: Interface Builder
    
    @IBAction func textChanged(_ sender: Any) {
        if passwordTextField.text != "" {
            continueButton.isEnabled = true
        } else {
            continueButton.isEnabled = false
        }
    }
    
    @IBAction func done(_ sender: Any) {
        view.endEditing(false)
    }
    
    @IBAction func dismissKeyboard(_ sender: Any) {
        view.endEditing(false)
    }
    
    // MARK: Functions for moving view up when keyboard is obscuring text field
    
    func registerForKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWasShown(notification: NSNotification){
        self.scrollView.isScrollEnabled = true
        let info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize!.height + 20.0, right: 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeField = self.activeField {
            if (!aRect.contains(activeField.frame.origin)){
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification){
        let info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: -keyboardSize!.height, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        view.endEditing(true)
        scrollView.isScrollEnabled = false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        activeField = nil
    }
    
}
