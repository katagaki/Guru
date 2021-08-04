//
//  IconCarousellCell.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/06/30.
//

import UIKit

class IconCarousellCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    public var isSelectable: Bool = false
    
    public var icons: [String] = []
    public var selectedIcon: UIImage = UIImage(named: "AI.001")!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return icons.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PWNewLoginIconCell", for: indexPath) as! IconCollectionViewCell
        let imageName = icons[indexPath.row]
        cell.imageView.image = UIImage(named: imageName)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isSelectable {
            let cell = collectionView.cellForItem(at: indexPath) as! IconCollectionViewCell
            selectedIcon = cell.imageView.image!
            cell.imageView.borderThickness = 2
            cell.imageView.borderColor = UIColor(named: "AccentColor")!
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if isSelectable {
            let cell = collectionView.cellForItem(at: indexPath) as! IconCollectionViewCell
            cell.imageView.borderThickness = 0.25
            cell.imageView.borderColor = UIColor.separator
        }
    }
    
}
