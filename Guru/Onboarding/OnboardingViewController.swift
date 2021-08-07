//
//  OnboardingViewController.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/04.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    // View controller for views with scroll view and visual effect view
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var primaryButton: StylizedButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.verticalScrollIndicatorInsets.bottom = visualEffectView.frame.height
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        log("\(self.className) has appeared.")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backButton = UIBarButtonItem()
        backButton.title = NSLocalizedString("Back", comment: "General")
        navigationItem.backBarButtonItem = backButton
    }
    
}
