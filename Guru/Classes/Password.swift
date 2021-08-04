//
//  Password.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/17.
//

import Foundation

public class Password: NSObject {
    
    public var generated: String = ""
    public var minLength: Int = 8
    public var maxLength: Int = 16
    public var policies: [PasswordCharacterPolicy] = [.ContainsUppercase, .ContainsLowercase, .ContainsNumbers, .ContainsBasicSymbols]
    
    private var wordCount: Int = 1
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    init(password: String) {
        super.init()
        generated = password
    }
    
    init(forPolicies policies: [PasswordCharacterPolicy], withMinLength lengthMin: Int, withMaxLength lengthMax: Int) {
        super.init()
        self.policies = policies
        minLength = lengthMin
        maxLength = lengthMax
        regenerate()
    }
    
    init(forPolicies policies: [PasswordCharacterPolicy], userProfile: UserProfile) {
        super.init()
        
        let chars: String = characterSet(forPolicies: policies)
        
        self.policies = policies
        
    }
    
    init(passphraseWithWordCount count: Int, withMinLength lengthMin: Int, withMaxLength lengthMax: Int) {
        super.init()
        policies = [.ContainsLowercase, .ContainsSpaces]
        minLength = lengthMin
        maxLength = lengthMax
        wordCount = count
        regeneratePassphrase()
    }
    
    // MARK: Functions for generating a new password
    
    /// Generates a fresh password from the currently set character policy set.
    public func regenerate() {
        repeat {
            let chars: String = characterSet(forPolicies: policies)
            let length: Int = cSRandomNumber(from: minLength, to: maxLength)
            generated = String((0..<length).compactMap{ _ in
                chars.randomElement()
            })
        } while (!acceptability(ofPassword: generated))
    }
    
    /// Generates a passphrase from the currently set word count.
    public func regeneratePassphrase() {
        let filteredWords: [String] = words.filter { word in
            return word.count <= ((maxLength - wordCount + 1) / wordCount) + (wordCount / 2)
        }
        repeat {
            var wordsToInclude: [String] = []
            for _ in 0..<wordCount {
                wordsToInclude.append(filteredWords[cSRandomNumber(to: filteredWords.count)])
            }
            generated = wordsToInclude.joined(separator: " ")
        } while (!(acceptability(ofPassword: generated) && generated.count >= minLength && generated.count <= maxLength))
    }
    
    // MARK: Functions for transforming the password
    
    /// Returns a transformation of the current password by replacing characters from a frequent characters dictionary containing characters and the frequency of the character.
    /// - Parameter chars: A dictionary of characters and their frequency.
    /// - Returns: The transformed password.
    public func transformed(withFrequentCharacters chars: [String:Double]) -> String {
        if chars.count == 0 {
            return generated
        } else {
            var newPassword: String = ""
            
            let willUseMoreFrequentCharacters: Bool = cSRandomNumber(from: 0, to: 10) >= 2
            let numberOfCharactersToReplace: Int = cSRandomNumber(to: Int(generated.count / 2))
            var characterIndexes: [Int] = []
            var characterSet: [String] = []
            characterSet = Array(chars.filter({ key, value in
                return (willUseMoreFrequentCharacters ? value >= 0.5 : value < 0.5)
            }).keys)
            
            let maxTries: Int = numberOfCharactersToReplace * generated.count
            var currentTries: Int = 0
            repeat {
                currentTries += 1
                newPassword = generated
                
                // Generate new indexes to replace
                for _ in 0..<numberOfCharactersToReplace {
                    var newIndex: Int = -1
                    repeat {
                        newIndex = cSRandomNumber(from: 0, to: generated.count)
                    } while characterIndexes.contains(where: { index in
                        return index == newIndex
                    })
                    characterIndexes.append(newIndex)
                }
                
                // Replace characters at indexes
                for characterIndex in characterIndexes {
                    newPassword = newPassword.replacingCharacter(in: characterIndex, to: characterSet[cSRandomNumber(to: characterSet.count)].character(in: 0))
                }
                
            } while (!acceptability(ofPassword: newPassword) && currentTries < maxTries)
            
            if currentTries >= maxTries {
                return generated
            } else {
                return newPassword
            }
        }
    }
    
    /// Transforms the current password by replacing characters from a frequent characters dictionary containing characters and the frequency of the character.
    /// - Parameter chars: A dictionary of characters and their frequency.
    /// - Returns: Whether the password was transformed.
    @discardableResult public func transform(withFrequentCharacters chars: [String:Double]) -> Bool {
        let originalPassword: String = generated
        generated = transformed(withFrequentCharacters: chars)
        if originalPassword != generated {
            return true
        } else {
            return false
        }
    }
    
    /// Returns a transformation of the current password by adding a word from the selected interest bank.
    /// - Parameter interest: The Interest object to use.
    /// - Returns: The transformed password.
    public func transformed(withInterest interest: Interest) -> String {
        var newPassword: String = ""
        
        let availableWords = interest.words.filter({ word in
            return word.count <= generated.count / 2
        })
        
        if availableWords.count > 0 {
            
            let maxTries: Int = (availableWords.count / 2) * (generated.count / 2)
            var currentTries: Int = 0
            
            repeat {
                currentTries += 1
                newPassword = generated
                
                // Get word and index to insert into the password
                var selectedWord: String = availableWords[cSRandomNumber(to: availableWords.count)]
                let indexToInsert: Int = cSRandomNumber(from: 0, to: generated.count - (selectedWord.count / 2))
                
                // Randomly capitalize first letter of word
                if cSCoinFlip() {
                    selectedWord = selectedWord.capitalized
                }
                
                // Insert word into password without changing length
                for i: Int in indexToInsert..<newPassword.count {
                    if i < indexToInsert + selectedWord.count {
                        newPassword = newPassword.replacingCharacter(in: i, to: selectedWord.character(in: i - indexToInsert))
                    }
                }
                
            } while (!acceptability(ofPassword: newPassword) && currentTries < maxTries)
            
            if currentTries >= maxTries {
                return generated
            } else {
                return newPassword
            }
        } else {
            return generated
        }
    }
    
    /// Transforms the current password by adding a word from the selected interest bank.
    /// - Parameter interest: The Interest object to use.
    /// - Returns: Whether the password was transformed.
    @discardableResult public func transform(withInterest interest: Interest) -> Bool {
        let originalPassword: String = generated
        generated = transformed(withInterest: interest)
        if originalPassword != generated {
            return true
        } else {
            return false
        }
    }
    
    /// Returns a leetified (l33tifi3d) transformation of the current password by randomly replacing characters in the password.
    /// - Returns: The transformed password.
    public func leetified() -> String {
        var leetified = Array(generated)
        for i: Int in 0..<leetified.count {
            if cSCoinFlip() {
                if let value = leetList[String(leetified[i])] {
                    leetified[i] = value.character(in: 0)
                }
            }
        }
        return String(leetified)
    }
    
    /// Leetifies (l33tifi3d) the current password by randomly replacing characters in the password.
    /// - Returns: Whether the password was transformed.
    @discardableResult public func leetify() -> Bool {
        let originalPassword: String = generated
        generated = leetified()
        if originalPassword != generated {
            return true
        } else {
            return false
        }
    }
    
    // MARK: Functions for getting parts of the password
    
    private func characterSet(forPolicies policies: [PasswordCharacterPolicy]) -> String {
        var chars: String = ""
        for policy in policies {
            chars += policy.rawValue.shuffled()
        }
        return chars
    }
    
    private func characterSet(forPolicy policy: PasswordCharacterPolicy, withLength length: Int) -> String {
        var finalChars: String = ""
        let validChars: String = characterSet(forPolicies: [policy])
        for _ in 0..<length {
            finalChars += String(validChars.character(in: cSRandomNumber(to: validChars.count)))
        }
        return finalChars
    }
    
    // MARK: Functions for checking the password
    
    public func acceptability(ofPassword password: String) -> Bool {
        var passwordAcceptable: Bool = true
        if password.trimmingCharacters(in: .whitespaces).count != password.count {
            return false
        } else {
            for policy in policies {
                if password.rangeOfCharacter(from: CharacterSet(charactersIn: policy.rawValue)) == nil {
                    passwordAcceptable = false
                }
            }
            return passwordAcceptable
        }
    }
    
    // MARK: Helper Functions
    
    public override var description: String {
        return generated
    }
    
}
