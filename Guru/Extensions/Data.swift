//
//  Data.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/07.
//

import Foundation

extension Data {
    
    private func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory as NSString
    }
    
    func dataToFile(fileName: String) -> NSURL? {
        
        let data = self
        let filePath = getDocumentsDirectory().appendingPathComponent(fileName)
        
        do {
            try data.write(to: URL(fileURLWithPath: filePath))
            return NSURL(fileURLWithPath: filePath)
        } catch {
            log("Data.dataToFile: \(error.localizedDescription)")
        }
        return nil
        
    }
    
}
