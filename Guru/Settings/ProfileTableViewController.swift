//
//  ProfileTableViewController.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/05/28.
//

import UIKit

class ProfileTableViewController: UITableViewController, HandlesTextField {
    
    @IBOutlet weak var editToggleButton: UIBarButtonItem!
    
    var languageSelectionActions: [UIAction] = []
    var interestSelectionActions: [UIAction] = []
    
    var fullName: String = ""
    var region: String = ""
    var company: String = ""
    var school: String = ""
    
    var currentViewTag: Int = 0
    var isEditingProfile: Bool = false

    // MARK: UIViewController
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        for language in builtInLanguages {
            let languageAction = UIAction(title: language, image: UIImage(systemName: "globe")) { [weak self] _ in
                if let userProfile = userProfile {
                    userProfile.languages.append(language)
                    self?.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
                }
            }
            languageSelectionActions.append(languageAction)
        }
        
        for interest in builtInInterests {
            let interestAction = UIAction(title: interest.name.capitalized, image: UIImage(systemName: "star")) { [weak self] _ in
                if let userProfile = userProfile {
                    userProfile.interests.append(interest.name)
                    self?.tableView.reloadSections(IndexSet(integer: 2), with: .automatic)
                }
            }
            interestSelectionActions.append(interestAction)
        }
        
        // Localization
        navigationItem.title = NSLocalizedString("Profile", comment: "Views")
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        languageSelectionActions.removeAll()
        interestSelectionActions.removeAll()
        super.viewDidDisappear(animated)
    }
    
    // MARK: Interface Builder
    
    @IBAction func toggleEditing(_ sender: Any) {
        if isEditingProfile {
            if let userProfile = userProfile {
                userProfile.fullName = fullName
                userProfile.region = region
                if let birthdayCell = tableView.cellForRow(at: IndexPath(row: 3 + userProfile.languages.count, section: 1)) as? DatePickerCell {
                    let dateFormatter:DateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy/MM/dd"
                    userProfile.set(birthday: dateFormatter.string(for: birthdayCell.datePicker.date)!)
                }
                userProfile.companyName = company
                userProfile.schoolName = school
            }
        } else {
            if let userProfile = userProfile {
                fullName = userProfile.fullName ?? ""
                region = userProfile.region ?? ""
                company = userProfile.companyName ?? ""
                school = userProfile.schoolName ?? ""
            }
        }
        isEditingProfile = !isEditingProfile
        editToggleButton.title = (isEditingProfile ? NSLocalizedString("Done", comment: "General") : NSLocalizedString("Edit", comment: "General"))
        tableView.reloadSections(IndexSet(integersIn: 1...2), with: .automatic)
    }
    
    // MARK: UITableViewController
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let userProfile = userProfile {
            switch section {
            case 0: return 1
            case 1:
                switch isEditingProfile {
                case true:
                    return userProfile.languages.count + 6
                case false:
                    return 6
                }
            case 2:
                switch isEditingProfile {
                case true:
                    return 1 + userProfile.interests.count
                case false:
                    if userProfile.interests.isEmpty {
                        return 1
                    } else {
                        return userProfile.interests.count
                    }
                }
            case 3: return 1
            default: return 0
            }
        } else {
            return 0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let _ = userProfile {
            return 4
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1: return NSLocalizedString("PII", comment: "Profile")
        case 2: return NSLocalizedString("Interests", comment: "Profile")
        default: return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 3: return NSLocalizedString("DeleteWarning", comment: "Profile")
        default: return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ExplainerCell") as! DetailWithImageCell
            cell.titleLabel.text = NSLocalizedString("ProfileExplainer", comment: "Profile")
            return cell
        case 1:
            if isEditingProfile {
                var languages: [String] = []
                if let userProfile = userProfile {
                    languages = userProfile.languages
                }
                switch indexPath.row {
                case 0:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "NameTextFieldCell") as! TextInputCell
                    cell.titleLabel.text = NSLocalizedString("FullName", comment: "Profile")
                    cell.textField.text = fullName
                    cell.textField.placeholder = NSLocalizedString("FullName", comment: "Profile")
                    cell.textFieldHandler = self
                    return cell
                case 1:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "RegionTextFieldCell") as! TextInputCell
                    cell.titleLabel.text = NSLocalizedString("Region", comment: "Profile")
                    cell.textField.text = region
                    cell.textField.placeholder = NSLocalizedString("Region", comment: "Profile")
                    cell.textFieldHandler = self
                    return cell
                case 2 + languages.count:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "AddLanguageCell") as! ButtonWithMenuCell
                    cell.primaryButton.setTitle(NSLocalizedString("AddLanguage", comment: "Profile"), for: .normal)
                    cell.primaryButton.showsMenuAsPrimaryAction = true
                    cell.primaryButton.menu = UIMenu(title: NSLocalizedString("AddLanguage", comment: "Profile"), children: languageSelectionActions.filter({ action in
                        if let userProfile = userProfile {
                            return !userProfile.languages.contains(action.title)
                        } else {
                            return false
                        }
                    }))
                    cell.primaryButton.contentHorizontalAlignment = .left
                    if #available(iOS 15.0, *) { } else {
                        cell.primaryButton.contentEdgeInsets.left = CGFloat(17.0)
                    }
                    return cell
                case 3 + languages.count:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "BirthdayCell") as! DatePickerCell
                    cell.titleLabel.text = NSLocalizedString("Birthday", comment: "Profile")
                    return cell
                case 4 + languages.count:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "CompanyTextFieldCell") as! TextInputCell
                    cell.titleLabel.text = NSLocalizedString("Company", comment: "Profile")
                    cell.textField.text = company
                    cell.textField.placeholder = NSLocalizedString("Company", comment: "Profile")
                    cell.textFieldHandler = self
                    return cell
                case 5 + languages.count:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SchoolTextFieldCell") as! TextInputCell
                    cell.titleLabel.text = NSLocalizedString("School", comment: "Profile")
                    cell.textField.text = school
                    cell.textField.placeholder = NSLocalizedString("School", comment: "Profile")
                    cell.textFieldHandler = self
                    return cell
                case 2...2 + languages.count:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageTextFieldCell") as! TextInputCell
                    cell.titleLabel.text = NSLocalizedString("Language", comment: "Profile")
                    cell.textField.text = languages[indexPath.row - 2]
                    cell.textFieldHandler = self
                    return cell
                default: return UITableViewCell()
                }
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileDetailCell")!
            switch indexPath.row {
            case 0:
                cell.textLabel!.text = NSLocalizedString("FullName", comment: "Profile")
                if let userProfile = userProfile, let fullName = userProfile.fullName {
                    cell.detailTextLabel!.text = fullName
                } else {
                    cell.detailTextLabel!.text = "-"
                }
            case 1:
                cell.textLabel!.text = NSLocalizedString("Region", comment: "Profile")
                if let userProfile = userProfile, let region = userProfile.region {
                    cell.detailTextLabel!.text = region
                } else {
                    cell.detailTextLabel!.text = "-"
                }
            case 2:
                cell.textLabel!.text = NSLocalizedString("Language", comment: "Profile")
                if let userProfile = userProfile {
                    cell.detailTextLabel!.text = NSLocalizedString("Languages", comment: "Profile").replacingOccurrences(of: "@$", with: "\(userProfile.languages.count)")
                    cell.selectionStyle = .none
                }
            case 3:
                cell.textLabel!.text = NSLocalizedString("Birthday", comment: "Profile")
                if let userProfile = userProfile, let birthday = userProfile.birthdayString() {
                    cell.detailTextLabel!.text = birthday
                } else {
                    cell.detailTextLabel!.text = "-"
                }
            case 4:
                cell.textLabel!.text = NSLocalizedString("Company", comment: "Profile")
                if let userProfile = userProfile, let companyName = userProfile.companyName {
                    cell.detailTextLabel!.text = companyName
                } else {
                    cell.detailTextLabel!.text = "-"
                }
            case 5:
                cell.textLabel!.text = NSLocalizedString("School", comment: "Profile")
                if let userProfile = userProfile, let schoolName = userProfile.schoolName {
                    cell.detailTextLabel!.text = schoolName
                } else {
                    cell.detailTextLabel!.text = "-"
                }
            default: break
            }
            return cell
        case 2:
            if let userProfile = userProfile {
                if isEditingProfile {
                    switch indexPath.row {
                    case 0 + userProfile.interests.count:
                        let cell = tableView.dequeueReusableCell(withIdentifier: "AddInterestCell") as! ButtonWithMenuCell
                        cell.primaryButton.setTitle(NSLocalizedString("AddInterest", comment: "Profile"), for: .normal)
                        cell.primaryButton.showsMenuAsPrimaryAction = true
                        cell.primaryButton.menu = UIMenu(title: NSLocalizedString("AddInterest", comment: "Profile"), children: interestSelectionActions.filter({ action in
                            return !userProfile.interests.contains(action.title.lowercased())
                        }))
                        cell.primaryButton.contentHorizontalAlignment = .left
                        if #available(iOS 15.0, *) { } else {
                            cell.primaryButton.contentEdgeInsets.left = CGFloat(17.0)
                        }
                        return cell
                    case 0..<userProfile.interests.count:
                        let cell = tableView.dequeueReusableCell(withIdentifier: "InterestDetailCell")!
                        cell.textLabel!.text = userProfile.interests[indexPath.row].capitalized
                        if let interest = builtInInterests.first(where: { interest in
                            return interest.name == userProfile.interests[indexPath.row].lowercased()
                        }) {
                            cell.detailTextLabel!.text = interest.words.joined(separator: ", ")
                        }
                        return cell
                    default: return UITableViewCell()
                    }
                } else {
                    if userProfile.interests.isEmpty {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "NoInterestsCell")!
                        cell.textLabel?.text = NSLocalizedString("NoInterests", comment: "Profile")
                        return cell
                    } else {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "InterestDetailCell")!
                        cell.textLabel!.text = userProfile.interests[indexPath.row].capitalized
                        if let interest = builtInInterests.first(where: { interest in
                            return interest.name == userProfile.interests[indexPath.row].lowercased()
                        }) {
                            cell.detailTextLabel!.text = interest.words.joined(separator: ", ")
                        }
                        return cell
                    }
                }
            } else {
                return UITableViewCell()
            }
        case 3:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ResetProfileCell")!
                cell.textLabel?.text = NSLocalizedString("DeleteProfile", comment: "Profile")
                return cell
            default: return UITableViewCell()
            }
        default: return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 3:
            switch indexPath.row {
            case 0:
                Guru.resetProfile(viewController: self)
            default: break
            }
        default: break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let userProfile = userProfile {
            if isEditingProfile {
                switch indexPath.section {
                case 1: return indexPath.row >= 2 && indexPath.row < 2 + userProfile.languages.count
                case 2: return indexPath.row < userProfile.interests.count && userProfile.interests.count > 0
                default: return false
                }
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let userProfile = userProfile {
                switch indexPath.section {
                case 1: userProfile.languages.remove(at: indexPath.row - 2)
                case 2: userProfile.interests.remove(at: indexPath.row)
                default: break
                }
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    // MARK: HandlesTextField
    
    func handleTextFieldShouldReturn() {
        if let view = view.viewWithTag(currentViewTag + 100) as? UITextField {
            log("Handling text field should return with tag \(currentViewTag).")
            currentViewTag += 100
            view.becomeFirstResponder()
        } else {
            log("Text field with tag \(currentViewTag + 100) not found.")
            currentViewTag = 0
            view.endEditing(false)
        }
    }
    
    func handleTextFieldBeginEditing(_ sender: UITextField) {
        log("Text field with tag \(sender.tag) started editing.")
        currentViewTag = sender.tag
    }
    
    func handleTextFieldEditingChanged(text: String, sender: Any) {
        if let sender = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: sender) {
            var languages: [String] = []
            if let userProfile = userProfile {
                languages = userProfile.languages
            }
            switch indexPath.section {
            case 1:
                switch indexPath.row {
                case 0: fullName = text
                case 1: region = text
                case 4 + languages.count: company = text
                case 5 + languages.count: school = text
                default: break
                }
            default: break
            }
        }
    }
    
}
