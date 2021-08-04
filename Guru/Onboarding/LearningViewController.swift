//
//  LearningViewController.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/06/13.
//

import UIKit

class LearningViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animateKeyframes(withDuration: 1.0, delay: 2.0, options: .allowUserInteraction, animations: {
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 3000)) {
                self.performSegue(withIdentifier: "ShowAllSet", sender: self)
            }
        }
    }
    
}
