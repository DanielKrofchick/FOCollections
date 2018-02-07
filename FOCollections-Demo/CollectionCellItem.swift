//
//  CollectionCellItem.swift
//  FOCollections
//
//  Created by Xiao Ma on 2015-11-20.
//  Copyright © 2015 Figure 1 Inc. All rights reserved.
//

import UIKit

class CollectionCellItem: FOCollectionItem {
    
    override func configure(_ cell: UICollectionViewCell, collectionView: UICollectionView, indexPath: IndexPath) {
        if let color = data as? UIColor {
            cell.contentView.backgroundColor = color
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        if let width = widthForCollectionView(collectionView, indexPath: indexPath) {
            return CGSize(width: width, height: width)
        } else {
            return CGSize(width: 50.0, height: 50.0)
        }
    }

}


