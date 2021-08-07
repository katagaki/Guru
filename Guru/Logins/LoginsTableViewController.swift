//
//  LoginsTableViewController.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/05/21.
//

import SwiftOTP
import UIKit

class LoginsTableViewController: UITableViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, ReloadsUserProfileData {
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    var floatingCopiedView: UIVisualEffectView = UIVisualEffectView()
    let floatingCopiedLabel: UILabel = singleLinedLabel(withText: NSLocalizedString("Copied", comment: "General"))
    
    var isSearching: Bool = false
    
    var indexNames: [String] = []
    var indexedLogins: [[Login]] = []
    var searchResults: [Login] = []
    var searchController: UISearchController?
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Configure search controller
        searchController = UISearchController(searchResultsController: nil)
        searchController?.delegate = self
        searchController!.searchResultsUpdater = self
        searchController!.searchBar.delegate = self
        searchController!.automaticallyShowsCancelButton = true
        searchController!.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // Configure floating copied view
        floatingCopiedView = floatingView(views: [floatingCopiedLabel], arrangeAs: .Vertical, margins: 10)
        center(view: floatingCopiedView, in: navigationController!.view)
        
        // Configure table view section index
        tableView.sectionIndexColor = UIColor(named: "AccentColor")
        tableView.sectionIndexBackgroundColor = .clear
        tableView.sectionIndexTrackingBackgroundColor = .clear
        
        // Localization
        navigationItem.title = NSLocalizedString("Logins", comment: "Views")
        editButton.title = NSLocalizedString("Edit", comment: "General")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        log("\(self.className) has appeared.")
        reloadIndex()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination
        switch segue.identifier {
        case "ShowNewLogin":
            if let navigationViewController = destinationViewController as? UINavigationController {
                for viewController: UIViewController in navigationViewController.viewControllers {
                    if let newLoginTableViewController = viewController as? NewLoginTableViewController {
                        newLoginTableViewController.reloadsUserProfileData = self
                        log("User is going to create a new login.")
                    }
                }
            }
        case "ShowLoginDetail":
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell), let accountTableViewController = destinationViewController as? LoginDetailTableViewController {
                switch isSearching {
                case true:
                    if let login = userProfile?.login(withName: searchResults[indexPath.row].accountName!) {
                        accountTableViewController.login = login
                    }
                case false:
                    accountTableViewController.login = indexedLogins[indexPath.section][indexPath.row]
                }
                accountTableViewController.reloadsUserProfileData = self
            }
        default: break
        }
    }
    
    // MARK: Interface Builder
    
    @IBAction func toggleEditing(_ sender: Any) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        editButton.title = (tableView.isEditing ?
                            NSLocalizedString("Done", comment: "General") :
                                NSLocalizedString("Edit", comment: "General"))
    }
    
    // MARK: UISearchResultsUpdating
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        searchResults = []
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        tableView.reloadData() //Sections(IndexSet(integer: 0), with: .automatic)
    }
    
    // MARK: UISearchBarDelegate
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearching = true
        tableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearching = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let userProfile = userProfile {
            searchResults = userProfile.logins.filter({ login in
                if let accountName = login.accountName {
                    return accountName.uppercased().contains(searchText.uppercased())
                } else {
                    return false
                }
            })
        }
    }
    
    // MARK: UITableViewController
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = userProfile {
            switch isSearching {
            case true: return searchResults.count
            case false: return indexedLogins[section].count
            }
        } else {
            return 0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let _ = userProfile {
            switch isSearching {
            case true: return 1
            case false: return indexedLogins.count
            }
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch isSearching {
        case true: return NSLocalizedString("SearchResults", comment: "Logins")
        case false: return indexNames[section]
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return indexNames
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell") as! DetailWithImageCell
        switch isSearching {
        case true:
            cell.iconView.image = searchResults[indexPath.row].accountIcon()
            cell.titleLabel.text = searchResults[indexPath.row].accountName
            cell.subtitleLabel.text = searchResults[indexPath.row].username
        case false:
            cell.iconView.image = indexedLogins[indexPath.section][indexPath.row].accountIcon()
            cell.titleLabel.text = indexedLogins[indexPath.section][indexPath.row].accountName
            cell.subtitleLabel.text = indexedLogins[indexPath.section][indexPath.row].username
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !isSearching
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete, let userProfile = userProfile {
            userProfile.remove(login: indexedLogins[indexPath.section][indexPath.row].accountName ?? "")
            if indexedLogins[indexPath.section].count == 1 {
                reloadIndex()
                tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
            } else {
                reloadIndex()
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            analyzePasswordCharacters()
        }
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil,
                                          actionProvider: { [weak self] suggestedActions in
            var children: [UIAction] = []
            if let userProfile = userProfile, let login = self?.indexedLogins[indexPath.section][indexPath.row], let accountName = login.accountName {
                let deleteAction = UIAction(title: NSLocalizedString("Delete", comment: "General"),
                                            image: UIImage(systemName: "trash"),
                                            attributes: .destructive) { [weak self] _ in
                    userProfile.remove(login: accountName)
                    self?.reloadIndex()
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
                let copyPasswordAction = UIAction(title: NSLocalizedString("CopyPassword", comment: "Logins"),
                                                  image: UIImage(systemName: "square.on.square")) { [weak self] _ in
                    if let password = login.password {
                        UIPasteboard.general.string = password
                        self?.showCopyPopup()
                    }
                }
                let copyOTPAction = UIAction(title: NSLocalizedString("CopyOTP", comment: "Logins"),
                                             image: UIImage(systemName: "square.on.square")) { [weak self] _ in
                    if let totpSecret = login.totpSecret, let data = base32DecodeToData(totpSecret) {
                        if let otp = TOTP(secret: data, digits: 6, timeInterval: 30, algorithm: .sha1)?.generate(time: Date()) {
                            UIPasteboard.general.string = otp
                            self?.showCopyPopup()
                        }
                    }
                }
                children.append(deleteAction)
                if login.password != nil { children.append(copyPasswordAction) }
                if login.totpSecret != nil { children.append(copyOTPAction) }
            }
            return UIMenu(title: "",
                          image: nil,
                          identifier: nil,
                          options: .displayInline,
                          children: children)
        })
    }
    
    // MARK: ReloadsUserProfileData
    
    func reloadUserProfileData() {
        reloadDataAndIndex()
    }
    
    // MARK: Helper Functions
    
    func reloadIndex() {
        if let userProfile = userProfile {
            let accountNameFirstLetters = userProfile.logins.map { String(($0.accountName ?? " ").character(in: 0)).uppercased() }
            indexNames = accountNameFirstLetters.unique()
            indexNames.sort()
            
            indexedLogins = indexNames.map { firstLetter in
                return userProfile.logins
                    .filter { String(($0.accountName ?? " ").character(in: 0)).uppercased() == firstLetter }
                    .sorted { String(($0.accountName ?? " ").character(in: 0)).uppercased() < String(($1.accountName ?? " ").character(in: 0)).uppercased() }
            }
        }
    }
    
    func reloadSectionAndIndex(section: Int) {
        reloadIndex()
        tableView.reloadSections(IndexSet(integer: section), with: .automatic)
    }
    
    func reloadDataAndIndex() {
        reloadIndex()
        tableView.reloadData()
    }
    
    func showCopyPopup() {
        UIView.animate(withDuration: 0.25, delay: 0.0, options: []) {
            self.floatingCopiedView.layer.opacity = 1.0
        } completion: { _ in
            UIView.animate(withDuration: 0.25, delay: 0.5, options: []) {
                self.floatingCopiedView.layer.opacity = 0.0
            } completion: { _ in }
        }
    }
    
}
