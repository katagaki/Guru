//
//  ResetProfile.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/28.
//

import UIKit

func resetProfile(viewController: UIViewController) {
    let resetProfileAlert = UIAlertController(title: NSLocalizedString("ConfirmationToResetTitle", comment: "ResetProfile"),
                                              message: NSLocalizedString("ConfirmationToResetText", comment: "ResetProfile"),
                                              preferredStyle: .alert)
    resetProfileAlert.addAction(UIAlertAction(title: NSLocalizedString("ConfirmationToResetYes", comment: "ResetProfile"),
                                              style: .destructive,
                                              handler: { _ in
        UserProfile().delete()
        defaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        defaults.synchronize()
        let confirmationAlert = UIAlertController(title: NSLocalizedString("ConfirmationOfResetTitle", comment: "ResetProfile"), message: NSLocalizedString("ConfirmationOfResetText", comment: "ResetProfile"), preferredStyle: .alert)
        confirmationAlert.addAction(UIAlertAction(title: NSLocalizedString("CloseGuru", comment: "ResetProfile"), style: .default, handler: { _ in
            exit(-1)
        }))
        viewController.present(confirmationAlert, animated: true, completion: nil)
    }))
    resetProfileAlert.addAction(UIAlertAction(title: NSLocalizedString("ConfirmationToResetNo", comment: "ResetProfile"), style: .cancel, handler: nil))
    viewController.present(resetProfileAlert, animated: true, completion: nil)
}
