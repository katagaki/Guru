//
//  OverlayViewController.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/09.
//

import UIKit

class OverlayViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = NSLocalizedString("OverlayTitle", comment: "Authentication")
        contentLabel.text = NSLocalizedString("OverlayText", comment: "Authentication")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        log("\(self.className) has appeared.")
    }
    
}
