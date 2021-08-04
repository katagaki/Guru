//
//  UpdatesFolderPreview.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/06/05.
//

import UIKit

protocol UpdatesFolderPreview: AnyObject {
    var folderIcon: UIImage { get set }
    var folderName: String { get set }
    func updateFolderPreview()
    func updateFolderPreview(newFolderName: String)
    func updateFolderPreview(newFolderIcon: UIImage)
}
