//
//  GeneratorTableViewController.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/05/23.
//

import UIKit

class GeneratorTableViewController: UITableViewController, UITextViewDelegate, HandlesCellButton, HandlesCellSliderValueChange {
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var floatingPasswordView: UIVisualEffectView = UIVisualEffectView()
    let floatingPasswordTitleLabel: UILabel = singleLinedLabel(withText: NSLocalizedString("PasswordFloatingPrefix", comment: "Profile"))
    let floatingPasswordLabel: UILabel = singleLinedMonoLabel(withText: "-")
    
    var floatingCopiedView: UIVisualEffectView = UIVisualEffectView()
    let floatingCopiedLabel: UILabel = singleLinedLabel(withText: NSLocalizedString("Copied", comment: "General"))
    
    // Basic mode variables
    var basicSelectedPolicyType: Int = 0
    let basicPolicyGroups: [[PasswordCharacterPolicy]] = [[.ContainsUppercase, .ContainsLowercase, .ContainsNumbers, .ContainsBasicSymbols], [.ContainsUppercase, .ContainsLowercase, .ContainsNumbers], [.ContainsUppercase, .ContainsLowercase], [.ContainsNumbers]]
    let basicPolicyMinLengths: [Int] = [8, 8, 8, 6]
    let basicPolicyMaxLengths: [Int] = [20, 16, 16, 6]
    
    // Enhanced mode variables
    var enhancedSelectedInterests: [Interest] = []
    
    // Custom mode variables
    var customContainsLowercase: Bool = true
    var customContainsUppercase: Bool = true
    var customContainsNumbers: Bool = true
    var customContainsSymbols: Bool = false
    var customContainsExtraSymbols: Bool = false
    var customContainsSpaces: Bool = false
    var customCharacterCount: Int = 8
    var customSelectedInterests: [Interest] = []
    
    var basicPassword: Password = Password(forPolicies: [.ContainsUppercase, .ContainsLowercase, .ContainsNumbers, .ContainsBasicSymbols], withMinLength: 8, withMaxLength: 20)
    var enhancedPassword: Password = Password(forPolicies: [.ContainsUppercase, .ContainsLowercase, .ContainsNumbers, .ContainsBasicSymbols], withMinLength: 8, withMaxLength: 16)
    var customPassword: Password = Password(forPolicies: [.ContainsLowercase, .ContainsUppercase, .ContainsNumbers], withMinLength: 8, withMaxLength: 8)
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        basicPassword.generated = ""
        enhancedPassword.generated = ""
        customPassword.generated = ""
        
        // Configure floating password view
        floatingPasswordView = floatingView(views: [floatingPasswordTitleLabel, floatingPasswordLabel], arrangeAs: .Vertical)
        float(view: floatingPasswordView, below: navigationController!.navigationBar, in: navigationController!.view, margins: 10)
        
        // Configure floating copied view
        floatingCopiedView = floatingView(views: [floatingCopiedLabel], arrangeAs: .Vertical, margins: 10)
        center(view: floatingCopiedView, in: navigationController!.view)
        
        segmentControl.selectedSegmentIndex = 0
        updatePasswordCell()
        updateSaveButton()
        updateFloatingView()
        
        // Localization
        navigationItem.title = NSLocalizedString("Generate", comment: "Views")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        switch segmentControl.selectedSegmentIndex {
        case 1: tableView.reloadSections(IndexSet(integer: 2), with: .none)
        case 2: tableView.reloadSections(IndexSet(integer: 4), with: .none)
        default: break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "ShowNewLogin":
            if let navigationController = segue.destination as? UINavigationController {
                if let destination = navigationController.viewControllers[0] as? NewLoginTableViewController {
                    if let passwordCell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? TextInputWithCopyCell {
                        destination.presetPassword = passwordCell.textView.text
                    }
                }
            }
        default: break
        }
    }
    
    // MARK: Interface Builder
    
    @IBAction func segmentChanged(_ sender: Any) {
        tableView.reloadData()
        updateSaveButton()
        updateFloatingView()
    }
    
    // MARK: UITextViewDelegate
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text as NSString).rangeOfCharacter(from: CharacterSet.newlines).location == NSNotFound {
            return true
        } else {
            view.endEditing(true)
            return false
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        saveButton.isEnabled = textView.text != ""
    }
    
    // MARK: UITableViewController
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            switch section {
            case 0: return 1
            case 1: return 2
            case 2: return 4
            default: return 0
            }
        case 1:
            switch section {
            case 0: return 1
            case 1: return 2
            case 2:
                if let userProfile = userProfile {
                    return userProfile.interests.count
                } else {
                    return 0
                }
            default: return 0
            }
        case 2:
            switch section {
            case 0: return 1
            case 1: return 2
            case 2: return 1
            case 3: return 6
            case 4:
                if let userProfile = userProfile {
                    return userProfile.interests.count
                } else {
                    return 0
                }
            default: return 0
            }
        default: return 0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        switch segmentControl.selectedSegmentIndex {
        case 0: return 3
        case 1: return 3
        case 2: return 5
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            switch section {
            case 1: return NSLocalizedString("NewPassword", comment: "Generator")
            case 2: return NSLocalizedString("PasswordPolicy", comment: "Generator")
            default: return ""
            }
        case 1:
            switch section {
            case 1: return NSLocalizedString("NewPassword", comment: "Generator")
            case 2: return NSLocalizedString("RecommendedTopics", comment: "Generator")
            default: return ""
            }
        case 2:
            switch section {
            case 1: return NSLocalizedString("NewPassword", comment: "Generator")
            case 2: return NSLocalizedString("NumberOfCharacters", comment: "Generator")
            case 3: return NSLocalizedString("CharactersToInclude", comment: "Generator")
            case 4: return NSLocalizedString("TopicsToInclude", comment: "Generator")
            default: return ""
            }
        default: return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 1 {
            return NSLocalizedString("NewPasswordHint", comment: "Generator").replacingOccurrences(of: "@$", with: NSLocalizedString("NewPassword", comment: "Generator"))
        }
        switch segmentControl.selectedSegmentIndex {
        case 0:
            switch section {
            case 2: return NSLocalizedString("PasswordPolicyExplainer", comment: "Generator")
            default: return ""
            }
        case 1:
            switch section {
            case 2: return NSLocalizedString("RecommendedTopicsExplainer", comment: "Generator")
            default: return ""
            }
        case 2:
            switch section {
            case 3: return NSLocalizedString("CharactersToIncludeExplainer", comment: "Generator")
            case 4: return NSLocalizedString("TopicsToIncludeExplainer", comment: "Generator")
            default: return ""
            }
        default: return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "PasswordTextFieldCell") as! TextInputWithCopyCell
                cell.textView.font = UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: UIFont(name: "Menlo", size: 16.0)!)
                switch segmentControl.selectedSegmentIndex {
                case 0: cell.textView.text = basicPassword.generated
                case 1: cell.textView.text = enhancedPassword.generated
                case 2: cell.textView.text = customPassword.generated
                default: break
                }
                cell.buttonHandler = self
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "RegenerateCell")!
                cell.textLabel?.text = NSLocalizedString("GenerateNewPassword", comment: "Generator")
                return cell
            default: return UITableViewCell()
            }
        }
        switch segmentControl.selectedSegmentIndex {
        case 0:
            switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ExplainerCell") as! DetailWithImageCell
                cell.iconView2.image = UIImage(systemName: "building.2")
                cell.titleLabel.text = NSLocalizedString("ExplainerBasic", comment: "Generator")
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell")!
                switch indexPath.row {
                case 0:
                    cell.textLabel?.text = NSLocalizedString("WorkSchool", comment: "Generator")
                    cell.detailTextLabel?.text = NSLocalizedString("WorkSchoolPolicy", comment: "Generator")
                case 1:
                    cell.textLabel?.text = NSLocalizedString("SensitivityLevel2", comment: "Generator")
                    cell.detailTextLabel?.text = NSLocalizedString("SensitivityLevel2Policy", comment: "Generator")
                case 2:
                    cell.textLabel?.text = NSLocalizedString("SensitivityLevel3", comment: "Generator")
                    cell.detailTextLabel?.text = NSLocalizedString("SensitivityLevel3Policy", comment: "Generator")
                case 3:
                    cell.textLabel?.text = NSLocalizedString("PIN", comment: "Generator")
                    cell.detailTextLabel?.text = NSLocalizedString("PINPolicy", comment: "Generator")
                default: break
                }
                if basicSelectedPolicyType == indexPath.row {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
                return cell
            default: return UITableViewCell()
            }
        case 1:
            switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ExplainerCell") as! DetailWithImageCell
                cell.iconView2.image = UIImage(systemName: "sparkles")
                cell.titleLabel.text = NSLocalizedString("ExplainerEnhanced", comment: "Generator")
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "InterestCell")!
                if let userProfile = userProfile {
                    cell.textLabel!.text = userProfile.interests[indexPath.row].capitalized
                    if let interest = builtInInterests.first(where: { interest in
                        return interest.name == userProfile.interests[indexPath.row].lowercased()
                    }) {
                        cell.detailTextLabel!.text = interest.words.joined(separator: ", ")
                    }
                    if enhancedSelectedInterests.contains(where: { interest in
                        return interest.name == userProfile.interests[indexPath.row]
                    }) {
                        cell.accessoryType = .checkmark
                    } else {
                        cell.accessoryType = .none
                    }
                }
                return cell
            default: return UITableViewCell()
            }
        case 2:
            switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ExplainerCell") as! DetailWithImageCell
                if #available(iOS 15.0, *) {
                    cell.iconView2.image = UIImage(systemName: "checklist")
                } else {
                    cell.iconView2.image = UIImage(named: "checklist")
                }
                cell.titleLabel.text = NSLocalizedString("ExplainerCustom", comment: "Generator")
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterCountCell") as! SliderCell
                cell.sliderValueChangeHandler = self
                cell.titleLabel.text = NSLocalizedString("LengthAverage", comment: "Generator")
                cell.titleLabel.textColor = .systemOrange
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell")!
                switch indexPath.row {
                case 0:
                    cell.textLabel?.text = NSLocalizedString("Lowercase", comment: "Generator")
                    cell.detailTextLabel?.text = "abcdefghijklmnopqrstuvwxyz"
                    cell.accessoryType = (customContainsLowercase ? .checkmark : .none)
                case 1:
                    cell.textLabel?.text = NSLocalizedString("Uppercase", comment: "Generator")
                    cell.detailTextLabel?.text = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                    cell.accessoryType = (customContainsUppercase ? .checkmark : .none)
                case 2:
                    cell.textLabel?.text = NSLocalizedString("Numbers", comment: "Generator")
                    cell.detailTextLabel?.text = "0123456789"
                    cell.accessoryType = (customContainsNumbers ? .checkmark : .none)
                case 3:
                    cell.textLabel?.text = NSLocalizedString("Symbols", comment: "Generator")
                    cell.detailTextLabel?.text = ".!-#$"
                    cell.accessoryType = (customContainsSymbols ? .checkmark : .none)
                case 4:
                    cell.textLabel?.text = NSLocalizedString("ExtraSymbols", comment: "Generator")
                    cell.detailTextLabel?.text = "%&^~`:+/\\|<>_" + NSLocalizedString("ExtraSymbolsDisclaimer", comment: "Generator")
                    cell.accessoryType = (customContainsExtraSymbols ? .checkmark : .none)
                case 5:
                    cell.textLabel?.text = NSLocalizedString("WhiteSpaces", comment: "Generator")
                    cell.detailTextLabel?.text = ""
                    cell.accessoryType = (customContainsSpaces ? .checkmark : .none)
                default: break
                }
                return cell
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: "InterestCell")!
                if let userProfile = userProfile {
                    cell.textLabel!.text = userProfile.interests[indexPath.row].capitalized
                    if let interest = builtInInterests.first(where: { interest in
                        return interest.name == userProfile.interests[indexPath.row].lowercased()
                    }) {
                        cell.detailTextLabel!.text = interest.words.joined(separator: ", ")
                    }
                    if customSelectedInterests.contains(where: { interest in
                        return interest.name == userProfile.interests[indexPath.row]
                    }) {
                        cell.accessoryType = .checkmark
                    } else {
                        cell.accessoryType = .none
                    }
                }
                return cell
            default: return UITableViewCell()
            }
        default: return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 1 {
            regeneratePassword()
        }
        switch segmentControl.selectedSegmentIndex {
        case 0:
            switch indexPath.section {
            case 2:
                let previousSelectedPolicyType: Int = basicSelectedPolicyType
                basicSelectedPolicyType = indexPath.row
                tableView.reloadRows(at: [IndexPath(row: previousSelectedPolicyType, section: 2), indexPath], with: .none)
                regeneratePassword()
            default: break
            }
        case 1:
            switch indexPath.section {
            case 2:
                if let userProfile = userProfile {
                    if enhancedSelectedInterests.contains(where: { interest in
                        return interest.name == userProfile.interests[indexPath.row]
                    }) {
                        enhancedSelectedInterests.removeAll(where: { interest in
                            return interest.name == userProfile.interests[indexPath.row]
                        })
                    } else {
                        if let interest = builtInInterests.first(where: { interest in
                            return interest.name == userProfile.interests[indexPath.row].lowercased()
                        }) {
                            enhancedSelectedInterests.append(interest)
                        }
                    }
                }
                tableView.reloadRows(at: [indexPath], with: .none)
            default: break
            }
        case 2:
            switch indexPath.section {
            case 3:
                switch indexPath.row {
                case 0: customContainsLowercase = !customContainsLowercase
                case 1: customContainsUppercase = !customContainsUppercase
                case 2: customContainsNumbers = !customContainsNumbers
                case 3: customContainsSymbols = !customContainsSymbols
                case 4: customContainsExtraSymbols = !customContainsExtraSymbols
                case 5: customContainsSpaces = !customContainsSpaces
                default: break
                }
                if !customContainsLowercase && !customContainsUppercase && !customContainsNumbers && !customContainsSymbols && !customContainsExtraSymbols {
                    customContainsLowercase = true
                    tableView.reloadRows(at: [IndexPath(row: 0, section: 3)], with: .none)
                }
                regeneratePassword()
                tableView.reloadRows(at: [indexPath], with: .none)
            case 4:
                if let userProfile = userProfile {
                    if customSelectedInterests.contains(where: { interest in
                        return interest.name == userProfile.interests[indexPath.row]
                    }) {
                        customSelectedInterests.removeAll(where: { interest in
                            return interest.name == userProfile.interests[indexPath.row]
                        })
                    } else {
                        if let interest = builtInInterests.first(where: { interest in
                            return interest.name == userProfile.interests[indexPath.row].lowercased()
                        }) {
                            customSelectedInterests.append(interest)
                        }
                    }
                }
                tableView.reloadRows(at: [indexPath], with: .none)
            default: break
            }
        default: break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if indexPath.section == 1 {
            switch indexPath.row {
            case 1:
                return UIContextMenuConfiguration(identifier: nil,
                                                  previewProvider: nil,
                                                  actionProvider: { suggestedActions in
                    let generatePasswordAction = UIAction(title: NSLocalizedString("GenerateNewPassword", comment: "Generator"),
                                                          image: UIImage(systemName: "ellipsis.rectangle")) { action in
                        self.regeneratePassword()
                    }
                    let generatePassphraseAction = UIAction(title: NSLocalizedString("GenerateNewPassphrase", comment: "Generator"),
                                                            image: UIImage(systemName: "text.book.closed")) { action in
                        switch self.segmentControl.selectedSegmentIndex {
                        case 0:
                            self.basicPassword = Password(passphraseWithWordCount: 4,
                                                          withMinLength: self.basicPassword.minLength,
                                                          withMaxLength: self.basicPassword.maxLength)
                        case 1:
                            self.enhancedPassword = Password(passphraseWithWordCount: 4,
                                                             withMinLength: self.enhancedPassword.minLength,
                                                             withMaxLength: self.enhancedPassword.maxLength)
                        case 2:
                            self.customPassword = Password(passphraseWithWordCount: 4,
                                                           withMinLength: self.customPassword.minLength,
                                                           withMaxLength: self.customPassword.maxLength)
                        default: break
                        }
                        self.updatePasswordCell()
                        self.updateSaveButton()
                        self.updateFloatingView()
                    }
                    let transformPasswordAction = UIAction(title: NSLocalizedString("TransformPassword", comment: "Generator"),
                                                           image: UIImage(systemName: "wand.and.stars")) { action in
                        switch self.segmentControl.selectedSegmentIndex {
                        case 0:
                            self.basicPassword.leetify()
                        case 1:
                            self.enhancedPassword.leetify()
                        case 2:
                            self.customPassword.leetify()
                        default: break
                        }
                        self.updatePasswordCell()
                        self.updateSaveButton()
                        self.updateFloatingView()
                    }
                    var children: [UIAction] = [generatePasswordAction]
                    switch self.segmentControl.selectedSegmentIndex {
                    case 0:
                        if self.basicPassword.maxLength >= 15 {
                            children.append(generatePassphraseAction)
                        }
                        if self.basicPassword.generated != "" {
                            children.append(transformPasswordAction)
                        }
                    case 1:
                        if self.enhancedPassword.maxLength >= 15 {
                            children.append(generatePassphraseAction)
                        }
                        if self.enhancedPassword.generated != "" {
                            children.append(transformPasswordAction)
                        }
                    case 2:
                        if self.customPassword.maxLength >= 15 {
                            children.append(generatePassphraseAction)
                        }
                        if self.customPassword.generated != "" {
                            children.append(transformPasswordAction)
                        }
                    default: break
                    }
                    return UIMenu(title: "",
                                  image: nil,
                                  identifier: nil,
                                  options: .displayInline,
                                  children: children)
                })
            default: return nil
            }
        } else {
            return nil
        }
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if tableView.indexPathsForVisibleRows!.contains(where: { indexPath in
            return indexPath.row == 0 && indexPath.section == 0
        }) {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: []) {
                self.floatingPasswordView.layer.opacity = 0.0
            } completion: { _ in }
        } else {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: []) {
                self.floatingPasswordView.layer.opacity = 1.0
            } completion: { _ in }
        }
    }
    
    // MARK: HandlesCellButton
    
    func handleCellButton() {
        UIView.animate(withDuration: 0.25, delay: 0.0, options: []) {
            self.floatingCopiedView.layer.opacity = 1.0
        } completion: { _ in
            UIView.animate(withDuration: 0.25, delay: 0.5, options: []) {
                self.floatingCopiedView.layer.opacity = 0.0
            } completion: { _ in }
        }
    }
    
    // MARK: HandlesCellSliderValueChange
    
    func handleCellValueChange(value: Int, label: UILabel) {
        if value != customCharacterCount {
            customCharacterCount = value
            if customCharacterCount >= 8 && customCharacterCount < 18 {
                label.text = NSLocalizedString("LengthAverage", comment: "Generator")
                label.textColor = .systemOrange
            } else if customCharacterCount >= 18 && customCharacterCount < 24 {
                label.text = NSLocalizedString("LengthModerate", comment: "Generator")
                label.textColor = .systemYellow
            } else if customCharacterCount >= 24 && customCharacterCount < 52 {
                label.text = NSLocalizedString("LengthSecure", comment: "Generator")
                label.textColor = .systemGreen
            } else if customCharacterCount >= 52 {
                label.text = NSLocalizedString("LengthVerySecure", comment: "Generator")
                label.textColor = .systemBlue
            } else {
                label.text = NSLocalizedString("LengthNotSecure", comment: "Generator")
                label.textColor = .systemRed
            }
            regeneratePassword()
        }
    }
    
    // MARK: Helper Functions
    
    func regeneratePassword() {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            log("Generating basic password.")
            basicPassword = Password(forPolicies: basicPolicyGroups[basicSelectedPolicyType],
                                     withMinLength: basicPolicyMinLengths[basicSelectedPolicyType],
                                     withMaxLength: basicPolicyMaxLengths[basicSelectedPolicyType])
            
            var availableInterests: [Interest] = []
            var availableInterestWordAverage: Int = 0
            var wordCount: Int = 0
            var characterCount: Int = 0
            if let userProfile = userProfile {
                for interestName in userProfile.interests {
                    if let foundInterest = builtInInterests.first(where: { interest in
                        return interest.name == interestName
                    }) {
                        availableInterests.append(foundInterest)
                    }
                }
            }
            for interest in availableInterests {
                for word in interest.words {
                    wordCount += 1
                    characterCount += word.count
                }
            }
            availableInterestWordAverage = Int(Double(characterCount) / Double(wordCount))
            
            var transformationsToApply: Int = basicPassword.generated.count / availableInterestWordAverage
            transformationsToApply = cSRandomNumber(to: transformationsToApply)
            log("Attempting to transform password \(transformationsToApply) times.")
            for _ in 0..<transformationsToApply {
                let transformationSuccessful: Bool = basicPassword.transform(withInterest: availableInterests.randomElement()!)
                log("Interest based transformation succeeded: \(transformationSuccessful).")
            }
            
        case 1:
            log("Generating enhanced password.")
            enhancedPassword = Password(forPolicies: [.ContainsUppercase, .ContainsLowercase, .ContainsNumbers, .ContainsBasicSymbols], withMinLength: 8, withMaxLength: 20)
            
            if enhancedSelectedInterests.count != 0 {
                var transformationsToApply: Int = enhancedPassword.generated.count / Int(interestWordAverage)
                transformationsToApply = cSRandomNumber(to: transformationsToApply)
                log("Attempting to transform password \(transformationsToApply) times.")
                for _ in 0..<transformationsToApply {
                    let transformationSuccessful: Bool = enhancedPassword.transform(withInterest: enhancedSelectedInterests.randomElement()!)
                    log("Interest based transformation succeeded: \(transformationSuccessful).")
                }
            }
            
        case 2:
            var characterPolicies: [PasswordCharacterPolicy] = []
            if customContainsLowercase { characterPolicies.append(.ContainsLowercase) }
            if customContainsUppercase { characterPolicies.append(.ContainsUppercase) }
            if customContainsNumbers { characterPolicies.append(.ContainsNumbers) }
            if customContainsSymbols { characterPolicies.append(.ContainsBasicSymbols) }
            if customContainsExtraSymbols { characterPolicies.append(.ContainsComplexSymbols) }
            if customContainsSpaces { characterPolicies.append(.ContainsSpaces) }
            
            log("Generating custom password based on policies: \(characterPolicies).")
            customPassword = Password(forPolicies: characterPolicies, withMinLength: customCharacterCount, withMaxLength: customCharacterCount)
            
            if let userProfile = userProfile, userProfile.interests.count > 0 {
                if customSelectedInterests.count != 0 {
                    var transformationsToApply: Int = customPassword.generated.count / Int(interestWordAverage)
                    transformationsToApply = cSRandomNumber(to: transformationsToApply)
                    log("Attempting to transform password \(transformationsToApply) times.")
                    for _ in 0..<transformationsToApply {
                        let transformationSuccessful: Bool = customPassword.transform(withInterest: customSelectedInterests.randomElement()!)
                        log("Interest based transformation succeeded: \(transformationSuccessful).")
                    }
                }
            } else {
                log("One or more conditions not met, no interest based transformation applied.")
            }
            
        default: break
        }
        updatePasswordCell()
        updateSaveButton()
        updateFloatingView()
    }
    
    func updatePasswordCell() {
        if let passwordCell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? TextInputWithCopyCell {
            switch segmentControl.selectedSegmentIndex {
            case 0: passwordCell.textView.text = basicPassword.generated
            case 1: passwordCell.textView.text = enhancedPassword.generated
            case 2: passwordCell.textView.text = customPassword.generated
            default: passwordCell.textView.text = ""
            }
        }
    }
    
    func updateSaveButton() {
        switch segmentControl.selectedSegmentIndex {
        case 0: saveButton.isEnabled = basicPassword.generated != ""
        case 1: saveButton.isEnabled = enhancedPassword.generated != ""
        case 2: saveButton.isEnabled = customPassword.generated != ""
        default: saveButton.isEnabled = false
        }
    }
    
    func updateFloatingView() {
        switch segmentControl.selectedSegmentIndex {
        case 0: floatingPasswordLabel.text = basicPassword.generated
        case 1: floatingPasswordLabel.text = enhancedPassword.generated
        case 2: floatingPasswordLabel.text =  customPassword.generated
        default: floatingPasswordLabel.text = "-"
        }
        if floatingPasswordLabel.text == "" {
            floatingPasswordLabel.text = "-"
        }
    }
    
}
