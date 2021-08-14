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
                case 0: destination.guideCode = "Guru"
                case 1: destination.guideCode = "Edge"
                case 2: destination.guideCode = "Chrome"
                case 3: destination.guideCode = "Safari"
                case 4: destination.guideCode = "OnePassword"
                default: break
                }
            }
        case "ShowImportInterests":
            if let sender = sender as? UITableViewCell, let destination = segue.destination as? ImportInterestsTableViewController {
                switch tableView.indexPath(for: sender)!.row {
//                case 0:
//                    destination.guideCode = "Google"
//                    destination.filename = ""
//                case 1:
//                    destination.guideCode = "Microsoft"
//                    destination.filename = "SearchRequestsAndQuery.csv"
                case 0:
                    destination.guideCode = "Twitter"
                    destination.filename = "personalization.js"
//                case 3:
//                    destination.guideCode = "Facebook"
//                    destination.filename = "your_topics.json"
//                case 4:
//                    destination.guideCode = "Instagram"
//                    destination.filename = "your_topics.json"
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
        case 1: return 4
        case 2: return 1
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
//            case 3:
//                cell.titleLabel.text = "Facebook"
//                cell.iconView.image = UIImage(named: "SV.Facebook")
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
            case 0:
                performSegue(withIdentifier: "ShowImportInterests", sender: tableView.cellForRow(at: indexPath))
            default:
                featureUnavailableAlert(self)
            }
            
        default: break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
