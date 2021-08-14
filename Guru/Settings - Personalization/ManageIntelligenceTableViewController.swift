//
//  ManageIntelligenceTableViewController.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/08/09.
//

import UIKit

class ManageIntelligenceTableViewController: UITableViewController {
    
    var sortedKeys: [String] = []
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let userProfile = userProfile {
            sortedKeys = userProfile.preferredWords.keys.sorted(by: <)
        }
        
        // Localization
        navigationItem.title = NSLocalizedString("ManageKnowledge", comment: "Personalization")
        
    }
    
    // MARK: UITableViewController
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: if let userProfile = userProfile { return sortedKeys.count } else { return 0 }
        case 1: return 1
        default: return 0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return NSLocalizedString("HistoricallyUsedWords", comment: "Personalization")
        default: return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0: return NSLocalizedString("HistoricallyUsedWordsExplainer", comment: "Personalization")
        case 1: return NSLocalizedString("DeleteKnowledgeDataExplainer", comment: "Personalization")
        default: return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell")!
            if let userProfile = userProfile {
                if let value = userProfile.preferredWords[sortedKeys[indexPath.row]] {
                    let numberOfTimesUsed: Int = value
                    cell.textLabel!.text = sortedKeys[indexPath.row]
                    cell.detailTextLabel!.text = (numberOfTimesUsed > 1 ? NSLocalizedString("HistoricallyUsedWordSubtitles", comment: "Personalization").replacingOccurrences(of: "@$1", with: String(numberOfTimesUsed)) : NSLocalizedString("HistoricallyUsedWordSubtitle", comment: "Personalization").replacingOccurrences(of: "@$1", with: String(numberOfTimesUsed)))
                }
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DeleteCell")!
            cell.textLabel!.text = NSLocalizedString("DeleteKnowledgeData", comment: "Personalization")
            return cell
        default: return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            
            let deleteIntelAlert = UIAlertController(title: NSLocalizedString("DeleteKnowledgeDataAlertTitle", comment: "Personalization"),
                                                      message: NSLocalizedString("DeleteKnowledgeDataAlertText", comment: "Personalization"),
                                                      preferredStyle: .alert)
            deleteIntelAlert.addAction(UIAlertAction(title: NSLocalizedString("DeleteKnowledgeDataAlertYes", comment: "Personalization"),
                                                     style: .default,
                                                      handler: { _ in
                log("Intelligence data cleared.")
                defaults.set(nil, forKey: "Feature.Intelligence.AnalyzedPasswords.Words")
                wordCountPerPassword.removeAll()
                if let userProfile = userProfile {
                    userProfile.preferredWords.removeAll()
                }
                self.sortedKeys.removeAll()
                tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                let confirmationAlert = UIAlertController(title: NSLocalizedString("ConfirmationOfKnowledgeDataDeletionTitle", comment: "Personalization"), message: NSLocalizedString("ConfirmationOfKnowledgeDataDeletionText", comment: "Personalization"), preferredStyle: .alert)
                confirmationAlert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "General"), style: .default, handler: nil))
                self.present(confirmationAlert, animated: true, completion: nil)
            }))
            deleteIntelAlert.addAction(UIAlertAction(title: NSLocalizedString("DeleteKnowledgeDataAlertNo", comment: "Personalization"), style: .cancel, handler: nil))
            present(deleteIntelAlert, animated: true, completion: nil)
            
        default: break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete, let userProfile = userProfile {
            userProfile.preferredWords.removeValue(forKey: sortedKeys[indexPath.row])
            sortedKeys.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
}
