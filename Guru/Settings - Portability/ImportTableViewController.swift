//
//  ImportTableViewController.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/07.
//

import UIKit
import UniformTypeIdentifiers

class ImportTableViewController: UITableViewController {
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Localization
        navigationItem.title = NSLocalizedString("ImportView", comment: "Views")
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "ShowImportLogins":
            if let sender = sender as? UITableViewCell, let destination = segue.destination as? ImportLoginsTableViewController {
                switch tableView.indexPath(for: sender)!.row {
                case 0: destination.guideCode = "Edge"
                case 1: destination.guideCode = "Chrome"
                case 2: destination.guideCode = "Safari"
                case 3: destination.guideCode = "OnePassword"
                default: break
                }
            }
        case "ShowImportInterests":
            if let sender = sender as? UITableViewCell, let destination = segue.destination as? ImportInterestsTableViewController {
                switch tableView.indexPath(for: sender)!.row {
//                case 0:
//                    destination.guideCode = "Google"
//                    destination.filename = ""
//                    destination.supportPageURL = "https://takeout.google.com"
//                case 1:
//                    destination.guideCode = "Microsoft"
//                    destination.filename = "SearchRequestsAndQuery.csv"
//                    destination.supportPageURL = "https://account.microsoft.com/privacy/download-data"
                case 0:
                    destination.guideCode = "Twitter"
                    destination.filename = "personalization.js"
                    destination.fileType = .javaScript
                    destination.supportPageURL = "https://twitter.com/settings/download_your_data"
                case 1:
                    destination.guideCode = "Facebook"
                    destination.filename = "your_topics.json"
                    destination.fileType = .json
                    destination.supportPageURL = "https://www.facebook.com/dyi"
//                case 4:
//                    destination.guideCode = "Instagram"
//                    destination.filename = "your_topics.json"
//                    destination.supportPageURL = "https://www.instagram.com/download/request"
                default: break
                }
                
            }
        default: break
        }
    }
    
    // MARK: UITableViewController
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 3
        case 2: return 2
        default: return 0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1: return NSLocalizedString("ImportLogins", comment: "Portability")
        case 2: return NSLocalizedString("ImportInterests", comment: "Portability")
        default: return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ExplainerCell") as! DetailWithImageCell
            cell.titleLabel.text = NSLocalizedString("ImportExplainer", comment: "Portability")
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImportSourceCell") as! DetailWithImageCell
            switch indexPath.row {
            case 0:
                cell.titleLabel.text = "Microsoft Edge"
                cell.iconView.image = UIImage(named: "PM.Edge")
            case 1:
                cell.titleLabel.text = "Google Chrome"
                cell.iconView.image = UIImage(named: "PM.Chrome")
            case 2:
                cell.titleLabel.text = "Safari"
                cell.iconView.image = UIImage(named: "PM.Safari")
            default: break
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImportSourceCell") as! DetailWithImageCell
            switch indexPath.row {
//            case 0:
//                cell.titleLabel.text = "Google"
//                cell.iconView.image = UIImage(named: "SV.Google")
//            case 1:
//                cell.titleLabel.text = "Microsoft"
//                cell.iconView.image = UIImage(named: "SV.Microsoft")
            case 0:
                cell.titleLabel.text = "Twitter"
                cell.iconView.image = UIImage(named: "SV.Twitter")
            case 1:
                cell.titleLabel.text = "Facebook"
                cell.iconView.image = UIImage(named: "SV.Facebook")
//            case 4:
//                cell.titleLabel.text = "Instagram"
//                cell.iconView.image = UIImage(named: "SV.Instagram")
            default: break
            }
            return cell
        default: return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            performSegue(withIdentifier: "ShowImportLogins", sender: tableView.cellForRow(at: indexPath))
        case 2:
            switch indexPath.row {
            case 0, 1:
                performSegue(withIdentifier: "ShowImportInterests", sender: tableView.cellForRow(at: indexPath))
            default:
                featureUnavailableAlert(self)
            }
            
        default: break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
