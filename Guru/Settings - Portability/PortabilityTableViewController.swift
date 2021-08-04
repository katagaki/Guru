//
//  PortabilityTableViewController.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/07.
//

import UIKit

class PortabilityTableViewController: UITableViewController {
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Localization
        navigationItem.title = NSLocalizedString("ImportExport", comment: "Views")
        
    }
    
    // MARK: UITableViewController
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 2
        default: return 0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ExplainerCell") as! DetailWithImageCell
            cell.titleLabel.text = NSLocalizedString("PortabilityExplainer", comment: "Portability")
            return cell
        case 1:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ImportCell")!
                cell.textLabel?.text = NSLocalizedString("Import", comment: "Portability")
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ExportCell")!
                cell.textLabel?.text = NSLocalizedString("Export", comment: "Portability")
                return cell
            default: return UITableViewCell()
            }
        default: return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
