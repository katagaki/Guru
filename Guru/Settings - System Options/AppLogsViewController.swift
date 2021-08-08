//
//  AppLogsViewController.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/07.
//

import UIKit

class AppLogsViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadLogs()
        
        // Localization
        navigationItem.title = NSLocalizedString("AppLogs", comment: "UnderTheHood")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadLogs()
    }
    
    @IBAction func shareLogs(_ sender: Any) {
        let file = textView.text.data(using: .utf8)!.dataToFile(fileName: "Guru-AppLog.txt")
        var filesToShare = [Any]()
        filesToShare.append(file!)
        let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: Helper Functions
    
    func reloadLogs() {
        textView.text = appLogs
    }
    
}
