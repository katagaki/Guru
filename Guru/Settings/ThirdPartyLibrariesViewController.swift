//
//  ThirdPartyLibrariesViewController.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/08.
//

import UIKit

class ThirdPartyLibrariesViewController: UIViewController {
    
    @IBOutlet weak var acknowledgementsText: UITextView!
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let path = Bundle.main.path(forResource: "Acknowledgements", ofType: "txt")!
        do {
            let acknowledgements: String = try String(contentsOfFile: path, encoding: .utf8)
            acknowledgementsText.text = acknowledgements
        } catch {
            acknowledgementsText.text = "😟 Acknowledgement files are missing! Perhaps someone modified the source code?"
        }
        
        // Localization
        navigationItem.title = NSLocalizedString("ThirdPartyLibraries", comment: "Views")
        
    }
    
}
