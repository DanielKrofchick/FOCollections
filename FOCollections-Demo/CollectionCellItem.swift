//
//  CollectionCellItem.swift
//  FOCollections
//
//  Created by Xiao Ma on 2015-11-20.
//  Copyright © 2015 Figure1. All rights reserved.
//

import UIKit

class CollectionCellItem: FOCollectionItem {
    
    override func configure(cell: UICollectionViewCell, collectionView: UICollectionView, indexPath: NSIndexPath) {
        if let color = data as? UIColor {
            cell.contentView.backgroundColor = color
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if let width = widthForCollectionView(collectionView, indexPath: indexPath) {
            return CGSize(width: width, height: width)
        } else {
            return CGSize(width: 50.0, height: 50.0)
        }
    }

}


