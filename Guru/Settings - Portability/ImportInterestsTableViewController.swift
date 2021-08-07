//
//  ImportInterestsTableViewController.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/08/06.
//

import SafariServices
import UIKit
import UniformTypeIdentifiers

class ImportInterestsTableViewController: UITableViewController, SFSafariViewControllerDelegate, UIDocumentPickerDelegate, ReportsProgress {
    
    var guideCode: String = ""
    var filename: String = ""
    
    var floatingActivityView: UIVisualEffectView = UIVisualEffectView()
    let floatingActivityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .large)
    let floatingActivityLabel: UILabel = singleLinedLabel(withText: NSLocalizedString("ImportingInterestsProgress", comment: "ImportInterests").replacingOccurrences(of: "@$", with: "0%"))
    
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
        case 0: return 2
        case 1: return 2
        default: return 0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return NSLocalizedString("DownloadDataFromWebsite", comment: "ImportInterests")
        case 1: return NSLocalizedString("SelectInterestsFile", comment: "ImportInterests")
        default: return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ExplainerCell")!
                cell.textLabel!.text = NSLocalizedString("DownloadDataFromWebsiteExplainer", comment: "ImportInterests").replacingOccurrences(of: "@$", with: guideCode)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "OpenSupportPageCell")!
                cell.textLabel!.text = NSLocalizedString("OpenDataDownloadPage", comment: "ImportInterests")
                return cell
            default: return UITableViewCell()
            }
        case 1:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FileNameToUploadCell")!
                cell.textLabel!.text = NSLocalizedString("SelectInterestsFileExplainer", comment: "ImportInterests").replacingOccurrences(of: "@$", with: filename)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SelectFileCell")!
                cell.textLabel?.text = NSLocalizedString("SelectFile...", comment: "General")
                return cell
            default: return UITableViewCell()
            }
        default: return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isImporting {
            switch indexPath.section {
            case 0:
                var supportPageURL: String = ""
                switch guideCode {
                case "Google": supportPageURL = "https://takeout.google.com"
                case "Microsoft": supportPageURL = "https://account.microsoft.com/privacy/download-data"
                case "Twitter": supportPageURL = "https://twitter.com/settings/download_your_data"
                case "Facebook": supportPageURL = "https://www.facebook.com/dyi"
                case "Instagram": supportPageURL = "https://www.instagram.com/download/request"
                default: supportPageURL = "https://mypwd.guru/support"
                }
                let safariViewController = SFSafariViewController(url: URL(string: supportPageURL)!)
                safariViewController.delegate = self
                present(safariViewController, animated: true)
            case 1:
                let documentTypes = UTType.types(tag: "js", tagClass: .filenameExtension, conformingTo: .javaScript)
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
                floatingActivityLabel.text = NSLocalizedString("ImportingInterestsProgress", comment: "ImportInterests").replacingOccurrences(of: "@$", with: "0%")
                UIView.animate(withDuration: 0.25, delay: 0.0, options: []) {
                    self.floatingActivityView.layer.opacity = 1.0
                } completion: { _ in
                    UIApplication.shared.isIdleTimerDisabled = true
                    DispatchQueue.global(qos: .background).async {
                        let importFromTwitterResult = userProfile.importTwitter(data: TwitterData(fromContents: contents), progressReporter: self)
                        if importFromTwitterResult.success {
                            let importAlertText: String = (importFromTwitterResult.notImportedCount == 0 ? NSLocalizedString("ImportInterestsCompletedText", comment: "ImportInterests").replacingOccurrences(of: "@$", with: String(self.importCount)) : NSLocalizedString("ImportInterestsIncompleteText", comment: "ImportInterests").replacingOccurrences(of: "@$1", with: String(self.importCount)).replacingOccurrences(of: "@$2", with: String(importFromTwitterResult.notImportedCount)))
                            DispatchQueue.main.async {
                                UIView.animate(withDuration: 0.25, delay: 0.0, options: []) {
                                    self.floatingActivityView.layer.opacity = 0.0
                                } completion: { _ in
                                    self.navigationItem.hidesBackButton = false
                                    UIApplication.shared.isIdleTimerDisabled = false
                                    self.floatingActivityIndicator.stopAnimating()
                                    self.isImporting = false
                                    let completedAlert = UIAlertController(title: NSLocalizedString("ImportInterestsCompletedTitle", comment: "ImportInterests"),
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
                            log("Successfully added interests from file.")
                        } else {
                            self.navigationItem.hidesBackButton = false
                            UIApplication.shared.isIdleTimerDisabled = false
                            self.floatingActivityIndicator.stopAnimating()
                            self.isImporting = false
                            let completedAlert = UIAlertController(title: NSLocalizedString("ImportInterestsErrorTitle", comment: "ImportInterests"),
                                                                   message: NSLocalizedString("ImportInterestsErrorText", comment: "ImportInterests").replacingOccurrences(of: "@$", with: String(self.importCount)),
                                                                   preferredStyle: .alert)
                            completedAlert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "General"),
                                                                   style: .default,
                                                                   handler: { _ in
                                self.navigationController?.popViewController(animated: true)
                            }))
                            self.present(completedAlert, animated: true, completion: nil)
                            log("An error occurred while added interests from file.")
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
            self.floatingActivityLabel.text = NSLocalizedString("ImportingInterestsProgress", comment: "ImportInterests").replacingOccurrences(of: "@$", with: "\(Int((progress / total) * 100))%")
        }
    }
    
}
