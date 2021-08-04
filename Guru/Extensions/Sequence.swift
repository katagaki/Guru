//
//  Sequence.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/07.
//

import Foundation

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}
