//
//  TwitterData.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/08/06.
//

import Foundation

class TwitterData: NSObject {
    
    var languages: [TwitterLanguage]?
    var interests: [TwitterInterest]?
    var shows: [String]?
    
    public override init() {
        super.init()
    }
    
    public init(fromContents contents: String) {
        let languagesJSON: String = contents.firstMatch(for: "\"languages\" : \\[[\\s\\S]+?\\]").replacingOccurrences(of: "\"languages\" : ", with: "")
        let interestsJSON: String = contents.firstMatch(for: "\"interests\" : \\[[\\s\\S]+?\\]").replacingOccurrences(of: "\"interests\" : ", with: "")
        let showsJSON: String = contents.firstMatch(for: "\"shows\" : \\[[\\s\\S]+?\\]").replacingOccurrences(of: "\"shows\" : ", with: "")
        languages = try? JSONDecoder().decode([TwitterLanguage].self, from: languagesJSON.data(using: .utf8)!)
        interests = try? JSONDecoder().decode([TwitterInterest].self, from: interestsJSON.data(using: .utf8)!)
        shows = try? JSONDecoder().decode([String].self, from: showsJSON.data(using: .utf8)!)
        log("Twitter data loaded with \(languages?.count ?? 0) language(s), \(interests?.count ?? 0) interests, and \(shows?.count ?? 0) show(s).")
    }
    
}
