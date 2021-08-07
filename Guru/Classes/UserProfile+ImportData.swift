//
//  UserProfile+ImportData.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/08/07.
//

import Foundation

extension UserProfile {
    
    func importTwitter(data: TwitterData, progressReporter: ReportsProgress? = nil) -> (success: Bool, notImportedCount: Int) {
        
        var currentCount: Int = 0
        var dataPointCount: Int = 0
        
        if data.languages != nil { dataPointCount += data.languages!.count }
        if data.interests != nil { dataPointCount += data.interests!.count }
        if data.shows != nil { dataPointCount += data.shows!.count }
        
        if let languages = data.languages {
            for language in languages {
                if let name = language.language,
                   let isDisabled = language.isDisabled,
                   (!name.containsNonLatinCharacters() && !isDisabled),
                   builtInLanguages.contains(where: { builtInLanguage in
                       return name.lowercased().contains(builtInLanguage.lowercased())
                   }),
                   !self.languages.contains(name.capitalized) {
                    log("Appending \(name.lowercased()) to languages.")
                    self.languages.append(name.capitalized)
                }
                currentCount += 1
                if let progressReporter = progressReporter {
                    progressReporter.updateProgress(progress: Double(currentCount), total: Double(dataPointCount))
                }
            }
        }
        
        if let interests = data.interests {
            for interest in interests {
                if let name = interest.name,
                   let isDisabled = interest.isDisabled,
                   (!name.containsNonLatinCharacters() && !isDisabled) {
                    if let newInterest = builtInInterests.first(where: { builtInInterest in
                        return name.lowercased() == builtInInterest.name.lowercased() || builtInInterest.words.contains(where: { word in
                            return word.lowercased() == name.lowercased()
                        })
                    }),
                       !self.interests.contains(newInterest.name.lowercased()) {
                        log("Appending \(name.lowercased()) to interests.")
                        self.interests.append(newInterest.name.lowercased())
                    }
                }
                currentCount += 1
                if let progressReporter = progressReporter {
                    progressReporter.updateProgress(progress: Double(currentCount), total: Double(dataPointCount))
                }
            }
        }
        
        if let shows = data.shows {
            for show in shows {
                if !show.containsNonLatinCharacters() {
                    if preferredWords.keys.contains(show.lowercased()) {
                        let count: Int = preferredWords[show.lowercased()]!
                        log("Updating \(show.lowercased()) to preferred words with count \(count + 1).")
                        preferredWords.updateValue(count + 1, forKey: show.lowercased())
                    } else {
                        log("Adding \(show.lowercased()) to preferred words with count 1.")
                        preferredWords.updateValue(1, forKey: show.lowercased())
                    }
                }
                currentCount += 1
                if let progressReporter = progressReporter {
                    progressReporter.updateProgress(progress: Double(currentCount), total: Double(dataPointCount))
                }
            }
        }
        
        return (true, dataPointCount - currentCount)
        
    }
    
}
