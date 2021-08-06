//
//  ImportLoginsTableViewController.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/25.
//

import UIKit
import UniformTypeIdentifiers

class ImportLoginsTableViewController: UITableViewController, UIDocumentPickerDelegate, ReportsProgress {
    
    var guideCode: String = ""
    
    var floatingActivityView: UIVisualEffectView = UIVisualEffectView()
    let floatingActivityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .large)
    let floatingActivityLabel: UILabel = singleLinedLabel(withText: NSLocalizedString("ImportingLoginsProgress", comment: "ImportLogins").replacingOccurrences(of: "@$", with: "0%"))
    
    var isImporting: Bool = false
    var importCount: Int = 0
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure floating activity view
        floatingActivityView = floatingView(views: [floatingActivityIndicator, floatingActivityLabel], arrangeAs: .Vertical)
        center(view: floatingActivityView, in: navigationController!.view)
        
        // Localization
        navigationItem.title = NSLocalizedString("ImportFrom", comment: "Portability").replacingOccurrences(of: "@$", with: guideCode)
        
    }
    
    // MARK: UITableViewController
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 4
        case 1: return 1
        default: return 0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "StepCell") as! DetailWithLargeImageCell
            cell.titleLabel.text = NSLocalizedString("Step\(indexPath.row + 1)", comment: "ImportLogins")
            cell.subtitleLabel.text = NSLocalizedString("\(guideCode)Step\(indexPath.row + 1)", comment: "ImportLogins")
            cell.largeImageView.image = UIImage(named: "\(guideCode)Step\(indexPath.row + 1)")
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectFileCell")!
            cell.textLabel?.text = NSLocalizedString("SelectFile...", comment: "ImportLogins")
            return cell
        default: return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isImporting {
            switch indexPath.section {
            case 1:
                let documentTypes = UTType.types(tag: "csv", tagClass: .filenameExtension, conformingTo: .commaSeparatedText)
                let documentPickerController = UIDocumentPickerViewController(forOpeningContentTypes: documentTypes)
                documentPickerController.delegate = self
                documentPickerController.isModalInPresentation = true
                present(documentPickerController, animated: true, completion: nil)
            default: break
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: UIDoumentPickerDelegate
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        log("User picked documents at \(urls).")
        isImporting = true
        do {
            _ = urls[0].startAccessingSecurityScopedResource()
            let contents = try String(contentsOf: urls[0], encoding: .utf8)
            if let userProfile = userProfile {
                navigationItem.hidesBackButton = true
                floatingActivityIndicator.startAnimating()
                floatingActivityLabel.text = NSLocalizedString("ImportingLoginsProgress", comment: "ImportLogins").replacingOccurrences(of: "@$", with: "0%")
                UIView.animate(withDuration: 0.25, delay: 0.0, options: []) {
                    self.floatingActivityView.layer.opacity = 1.0
                } completion: { _ in
                    UIApplication.shared.isIdleTimerDisabled = true
                    DispatchQueue.global(qos: .background).async {
                        let addCSVResult = userProfile.addLogins(fromCSV: contents, progressReporter: self)
                        if addCSVResult.success {
                            let importAlertText: String = (addCSVResult.notImportedCount == 0 ? NSLocalizedString("ImportLoginsCompletedText", comment: "ImportLogins").replacingOccurrences(of: "@$", with: String(self.importCount)) : NSLocalizedString("ImportIncompleteText", comment: "ImportLogins").replacingOccurrences(of: "@$1", with: String(self.importCount)).replacingOccurrences(of: "@$2", with: String(addCSVResult.notImportedCount)))
                            DispatchQueue.main.async {
                                UIView.animate(withDuration: 0.25, delay: 0.0, options: []) {
                                    self.floatingActivityView.layer.opacity = 0.0
                                } completion: { _ in
                                    self.navigationItem.hidesBackButton = false
                                    UIApplication.shared.isIdleTimerDisabled = false
                                    self.floatingActivityIndicator.stopAnimating()
                                    self.isImporting = false
                                    let completedAlert = UIAlertController(title: NSLocalizedString("ImportLoginsCompletedTitle", comment: "ImportLogins"),
                                                                           message: importAlertText,
                                                                           preferredStyle: .alert)
                                    completedAlert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "General"),
                                                                           style: .default,
                                                                           handler: { _ in
                                            self.navigationController?.popViewController(animated: true)
                                    }))
                                    self.present(completedAlert, animated: true, completion: nil)
                                }
                            }
                            log("Successfully added logins from the CSV.")
                        } else {
                            self.navigationItem.hidesBackButton = false
                            UIApplication.shared.isIdleTimerDisabled = false
                            self.floatingActivityIndicator.stopAnimating()
                            self.isImporting = false
                            let completedAlert = UIAlertController(title: NSLocalizedString("ImportErrorTitle", comment: "ImportLogins"),
                                                                   message: NSLocalizedString("ImportErrorText", comment: "ImportLogins").replacingOccurrences(of: "@$", with: String(self.importCount)),
                                                                   preferredStyle: .alert)
                            completedAlert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "General"),
                                                                   style: .default,
                                                                   handler: { _ in
                                self.navigationController?.popViewController(animated: true)
                            }))
                            self.present(completedAlert, animated: true, completion: nil)
                            log("An error occurred while adding logins from the CSV.")
                        }
                    }
                }
                
            }
        } catch {
            log("An error occurred while reading the document from \(urls).")
            isImporting = false
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        log("User cancelled the document picker.")
    }
    
    // MARK: ReportsProgress
    
    func updateProgress(progress: Double, total: Double) {
        importCount = Int(total)
        DispatchQueue.main.async {
            self.floatingActivityLabel.text = NSLocalizedString("ImportingLoginsProgress", comment: "ImportLogins").replacingOccurrences(of: "@$", with: "\(Int((progress / total) * 100))%")
        }
    }
    
}
