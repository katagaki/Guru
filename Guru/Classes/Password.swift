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
        
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    init(password: String) {
        super.init()
        generated = password
    }
    
    init(forPolicies policies: [PasswordCharacterPolicy], withMinLength lengthMin: Int, withMaxLength lengthMax: Int, ignoresSimilarity: Bool = false) {
        super.init()
        self.policies = policies
        minLength = lengthMin
        maxLength = lengthMax
        regenerate(ignoresSimilarity: ignoresSimilarity)
    }
    
    init(forPolicies policies: [PasswordCharacterPolicy], withMinLength lengthMin: Int, withMaxLength lengthMax: Int, withInterests interests: [Interest] = [], usingPreferredWords preferredWords: [String:Int] = [:]) {
        super.init()
        self.policies = policies
        minLength = lengthMin
        maxLength = lengthMax
        regeneratePassphrase(withInterests: interests, usingPreferredWords: preferredWords)
    }
    
    // MARK: Functions for generating a new password
    
    /// Generates a fresh password from the currently set character policy set.
    public func regenerate(ignoresSimilarity: Bool = false) {
        repeat {
            let chars: String = characterSet(forPolicies: policies)
            let length: Int = cSRandomNumber(from: minLength, to: maxLength)
            generated = String((0..<length).compactMap{ _ in
                chars.randomElement()
            })
        } while (!acceptability(ofPassword: generated) && (ignoresSimilarity ? true : !similarity(ofPassword: generated)))
    }
    
    /// Generates a passphrase from the currently set word count.
    public func regeneratePassphrase(withInterests interests: [Interest] = [], usingPreferredWords preferredWords: [String:Int] = [:]) {
        
        let queue = DispatchQueue(label: "Password.regeneratePassphrase", attributes: .concurrent)
        let wordCount = cSRandomNumber(from: 2 + (minLength / 10), to: 3 + (maxLength / 10))
        let wordMinLength = ((minLength - (wordCount - 1)) / wordCount) + 1
        let wordMaxLength = ((maxLength - (wordCount - 1)) / wordCount)
        var validPasswords: [String] = []
        var passwordIterationCount: Int = 0

        log("Beginning passphrase generation with \(wordCount) words between \(wordMinLength) to \(wordMaxLength) characters.")
        
        repeat {
            // Always concurrently generate 4 passwords for checking
            DispatchQueue.concurrentPerform(iterations: 16) { i in
                
                var newPassword: String = ""
                var wordsToInclude: [String] = []
                var validSeparators: [String] = []
                for _ in 0..<wordCount {
                    var wordToAppend: String = ""
                    
                    repeat {
                        let randomWord: String = builtInWords[cSRandomNumber(to: builtInWords.count)]
                        if randomWord.count >= wordMinLength && randomWord.count <= wordMaxLength {
                            wordToAppend = randomWord
                        }
                    } while wordToAppend == ""
                    
                    // Randomly make into interest words
                    if !interests.isEmpty && (cSRandomNumber(to: 10) >= 2) {
                        wordToAppend = interests.randomElement()!.words.randomElement()!
                    }
                    
                    wordsToInclude.append(wordToAppend)
                }
                
                // Randomly make a word in the array a preferred word
                if !preferredWords.isEmpty && (cSRandomNumber(to: 10) >= 3) {
                    let sortedPreferredWords = userProfile?.preferredWords.sorted(by: { a, b in
                        return a.value >= b.value
                    })
                    let wordSelected: String = (cSRandomNumber(to: 10) >= 3 ?
                                                sortedPreferredWords![0..<min(10, sortedPreferredWords!.count)].randomElement()!.key :
                                                    sortedPreferredWords!.randomElement()!.key)
                    wordsToInclude[cSRandomNumber(to: wordsToInclude.count)] = wordSelected
                }
                
                // Randomly capitalize first letter of word
                if policies.contains(.ContainsUppercase) {
                    let index: Int = cSRandomNumber(to: wordsToInclude.count)
                    wordsToInclude[index] = wordsToInclude[index].capitalized
                }
                
                // Apply separator
                if policies.contains(.ContainsSpaces) {
                    validSeparators.append(" ")
                }
                if policies.contains(.ContainsBasicSymbols) {
                    validSeparators.append(contentsOf: ["-", ".", "_"])
                }
                if policies.contains(.ContainsComplexSymbols) {
                    validSeparators.append("+")
                }
                if !policies.contains(.ContainsSpaces) && !policies.contains(.ContainsBasicSymbols) && !policies.contains(.ContainsComplexSymbols) {
                    validSeparators.append("")
                }
                newPassword = wordsToInclude.joined(separator: validSeparators.randomElement()!)
                
                // Randomly convert to symbols/numbers
                if policies.contains(.ContainsNumbers) {
                    newPassword = leetified(newPassword)
                }
                
                queue.async(flags: .barrier) {
                    if self.acceptability(ofPassword: newPassword) && newPassword.count >= self.minLength && newPassword.count <= self.maxLength {
                        validPasswords.append(newPassword)
                    }
                }
            }
            passwordIterationCount += 16
            
            let semaphore = DispatchSemaphore(value: 0)
            queue.async(flags: .barrier) {
                semaphore.signal()
            }
            semaphore.wait()
            
        } while validPasswords.isEmpty
        
        log("Picked valid passphrase after \(passwordIterationCount) iteration(s).")
        generated = validPasswords.randomElement()!
    }
    
    // MARK: Functions for transforming the password
    
    /// Returns a transformation of the current password by replacing characters from a frequent characters dictionary containing characters and the frequency of the character.
    /// - Parameter chars: A dictionary of characters and their frequency.
    /// - Returns: The transformed password.
    public func transformed(withFrequentCharacters chars: [Character:Int]) -> String {
        if chars.isEmpty {
            return generated
        } else {
            var newPassword: String = ""
            
            let willUseMoreFrequentCharacters: Bool = cSRandomNumber(from: 0, to: 10) >= 2
            let numberOfCharactersToReplace: Int = cSRandomNumber(to: Array(generated).filter({ char in
                return char.isSymbol
            }).count)
            var characterIndexes: [Int] = []
            let sortedCharacterSet: [(Character, Int)] = (willUseMoreFrequentCharacters ? chars.sorted(by: { a, b in
                return a.value < b.value
            }) : chars.sorted(by: { a, b in
                return a.value > b.value
            }))
            let characterSet: [Character] = sortedCharacterSet.reduce([]) { partialResult, keyValuePair in
                var newResult = partialResult
                newResult.append(keyValuePair.0)
                return newResult
            }
            
            let maxTries: Int = numberOfCharactersToReplace * generated.count
            var currentTries: Int = 0
            repeat {
                currentTries += 1
                newPassword = generated
                
                // Generate new indexes to replace
                characterIndexes.removeAll()
                for _ in 0..<numberOfCharactersToReplace {
                    var newIndex: Int = -1
                    repeat {
                        newIndex = cSRandomNumber(from: 0, to: generated.count)
                    } while !(Array(generated)[newIndex].isSymbol || Array(generated)[newIndex].isPunctuation || Array(generated)[newIndex].isWhitespace || Array(generated)[newIndex].isCurrencySymbol || Array(generated)[newIndex].isMathSymbol) && characterIndexes.contains(where: { index in
                        return index == newIndex
                    })
                    characterIndexes.append(newIndex)
                }
                
                // Replace characters at indexes
                for characterIndex in characterIndexes {
                    newPassword = newPassword.replacingCharacter(in: characterIndex, to: characterSet[cSRandomNumber(to: characterSet.count)])
                }
                
            } while (!acceptability(ofPassword: newPassword) && !similarity(ofPassword: newPassword) && currentTries < maxTries)
            
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
    @discardableResult public func transform(withFrequentCharacters chars: [Character:Int]) -> Bool {
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
                
                let averageLengthOfInterestWords: Double = Double(interest.words.reduce(0) { partialResult, word in
                    return partialResult + word.count
                }) / Double(interest.words.count)
                let maxNumberOfWords: Int = Int(Double(newPassword.count) / averageLengthOfInterestWords)
                let numberOfWordsToAdd: Int = cSRandomNumber(from: 1, to: maxNumberOfWords)
                
                for _ in 0..<numberOfWordsToAdd {
                    
                    // Get word and index to insert into the password
                    var selectedWord: String = availableWords[cSRandomNumber(to: availableWords.count)]
                    let indexToInsert: Int = cSRandomNumber(from: 0, to: generated.count - (selectedWord.count / 2))
                    
                    // Randomly capitalize first letter of word
                    if policies.contains(.ContainsUppercase) && cSCoinFlip() {
                        selectedWord = selectedWord.capitalized
                    }
                    
                    // Insert word into password without changing length
                    for i: Int in indexToInsert..<newPassword.count {
                        if i < indexToInsert + selectedWord.count {
                            newPassword = newPassword.replacingCharacter(in: i, to: selectedWord.character(in: i - indexToInsert))
                        }
                    }
                    
                }
                
            } while (!acceptability(ofPassword: newPassword) && !similarity(ofPassword: newPassword) && currentTries < maxTries)
            
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
        return leetified(generated)
    }
    
    /// Returns a leetified (l33tifi3d) transformation of the current password by randomly replacing characters in the password.
    /// - Returns: The transformed password.
    public func leetified(_ password: String) -> String {
        var leetified = Array(password)
        for i: Int in 0..<leetified.count {
            if cSRandomNumber(to: 10) >= 7 {
                if let value = builtInLeetList[String(leetified[i])] {
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
    
    public func similarity(ofPassword password: String) -> Bool {
        let characters: [Character] = Array(password)
        let uppercaseLetters: [Character] = characters.filter { char in
            return char.isUppercase
        }
        let lowercaseLetters: [Character] = characters.filter { char in
            return char.isLowercase
        }
        let numbers: [Character] = characters.filter { char in
            return char.isNumber || char.isWholeNumber
        }
        let symbols: [Character] = characters.filter { char in
            return char.isSymbol || char.isPunctuation || char.isWhitespace || char.isCurrencySymbol || char.isMathSymbol
        }
        let uppercaseRatio: Double = Double(uppercaseLetters.count) / Double(characters.count)
        let lowercaseRatio: Double = Double(lowercaseLetters.count) / Double(characters.count)
        let numberRatio: Double = Double(numbers.count) / Double(characters.count)
        let symbolRatio: Double = Double(symbols.count) / Double(characters.count)
        let similarity: Bool = uppercaseRatio > averageUppercaseRatio - 0.175 && uppercaseRatio < averageUppercaseRatio + 0.175 &&
        lowercaseRatio > averageLowercaseRatio - 0.25 && lowercaseRatio < averageLowercaseRatio + 0.25 &&
        numberRatio > averageNumberRatio - 0.05 && numberRatio < averageNumberRatio + 0.05 &&
        symbolRatio > averageSymbolRatio - 0.025 && symbolRatio < averageSymbolRatio + 0.025
        return similarity
    }
    
    // MARK: Helper Functions
    
    public override var description: String {
        return generated
    }
    
}
