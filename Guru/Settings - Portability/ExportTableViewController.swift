//
//  ExportTableViewController.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/07.
//

import ZipArchive
import UIKit

class ExportTableViewController: UITableViewController, HandlesTextField {
    
    var exportType: CSVType = .Guru
    var selectedDestinationIndex: Int = -1
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Localization
        navigationItem.title = NSLocalizedString("ExportLogins", comment: "Views")
        
    }
    
    // MARK: UITableViewController
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 4
        case 2: return 1
        case 3: return (selectedDestinationIndex == -1 ? 0 : 1)
        default: return 0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1: return NSLocalizedString("ExportDestination", comment: "Portability")
        default: return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ExplainerCell") as! DetailWithImageCell
            cell.titleLabel.text = NSLocalizedString("ExportExplainer", comment: "Portability")
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DestinationTypeCell")! as! DetailWithImageCell
            switch indexPath.row {
            case 0:
                cell.titleLabel.text = "Guru"
                cell.iconView.image = UIImage(named: "AppIcon")
            case 1:
                cell.titleLabel.text = "Microsoft Edge"
                cell.iconView.image = UIImage(named: "PM.Edge")
            case 2:
                cell.titleLabel.text = "Google Chrome"
                cell.iconView.image = UIImage(named: "PM.Chrome")
            case 3:
                cell.titleLabel.text = "Safari"
                cell.iconView.image = UIImage(named: "PM.Safari")
            default: break
            }
            if indexPath.row == selectedDestinationIndex {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PasswordCell") as! TextInputCell
            cell.textField.placeholder = NSLocalizedString("ExportPassword", comment: "Portability")
            cell.textFieldHandler = self
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ExportCell")!
            cell.textLabel?.text = NSLocalizedString("Export", comment: "Portability")
            return cell
        default: return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let userProfile = userProfile {
            switch indexPath.section {
            case 1:
                selectedDestinationIndex = indexPath.row
                switch indexPath.row {
                case 0:
                    exportType = .Guru
                case 1, 2:
                    exportType = .Chromium
                case 3:
                    exportType = .Safari
                default: break
                }
                tableView.reloadSections(IndexSet(arrayLiteral: 1, 3), with: .automatic)
            case 3:
                
                var filesToShare = [Any]()
                let documentsPath: URL = FileManager.default.urls(for:.documentDirectory, in: .userDomainMask)[0]
                let zipContentsPath: URL = documentsPath.appendingPathComponent("CSV")
                let csvFilePath: URL = zipContentsPath.appendingPathComponent(NSLocalizedString("ExportFilename", comment: "Portability") + ".csv")
                let zipFilePath: URL = documentsPath.appendingPathComponent(NSLocalizedString("ExportFilename", comment: "Portability") + ".zip")
                
                // Reset temporary directory
                do {
                    try FileManager.default.removeItem(atPath: zipContentsPath.path)
                } catch {
                    log("Could not delete the temporary directory, this is normal as it may not exist yet.")
                    log(error.localizedDescription)
                }
                do {
                    try FileManager.default.createDirectory(atPath: zipContentsPath.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    log("Could not create the temporary directory, this may cause some problems.")
                    log(error.localizedDescription)
                }
                
                
                log("Preparing to write CSV to \(csvFilePath.path).")
                log("Preparing to write ZIP to \(zipFilePath.path).")
                
                // Generate CSV
                let content: String = userProfile.csv(ofType: exportType)
                try! content.write(to: csvFilePath, atomically: true, encoding: .utf8)
                
                if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? TextInputCell {
                    if cell.textField.text != "" {
                        // Use encrypted ZIP
                        SSZipArchive.createZipFile(atPath: zipFilePath.path,
                                                   withContentsOfDirectory: zipContentsPath.path,
                                                   keepParentDirectory: false,
                                                   compressionLevel: 4,
                                                   password: cell.textField.text!.trimmingCharacters(in: .whitespacesAndNewlines),
                                                   aes: true,
                                                   progressHandler: nil)
                        filesToShare.append(zipFilePath)
                    } else {
                        // Use unencrypted CSV
                        filesToShare.append(csvFilePath)
                    }
                }
                
                // Open share sheet
                let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
                self.present(activityViewController, animated: true, completion: nil)
            default: break
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: HandlesCellTextField
    
    func handleTextFieldShouldReturn() {
        view.endEditing(false)
    }
    
    func handleTextFieldBeginEditing(_ sender: UITextField) {
        // No action required
    }
    
    func handleTextFieldEditingChanged(text: String, sender: Any) {
        // No action required
    }
    
}
