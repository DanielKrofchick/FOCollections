//
//  FOPagingCollectionItem.swift
//  FOCollections
//
//  Created by Xiao Ma on 2015-11-20.
//  Copyright © 2015 Figure1. All rights reserved.
//

import UIKit

public let collectionPagingItemReuseIdentifier = "pagingItemResuseIdentifier"

class FOCollectionPagingItem: FOCollectionItem {
    
    init(section: FOCollectionSection) {
        super.init()
        
        identifier = "pagingItem-\(section.identifier)"
        reuseIdentifier = collectionPagingItemReuseIdentifier
        cellClass = UICollectionViewCell.self
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var width = collectionView.frame.size.width
        
        if let collectionViewLayout = collectionViewLayout as? UICollectionViewFlowLayout, viewController = viewController as? UICollectionViewDelegateFlowLayout {
            if let sectionInsets = viewController.collectionView?(collectionView, layout: collectionViewLayout, insetForSectionAtIndex: indexPath.section) {
                width = collectionView.frame.size.width - sectionInsets.left - sectionInsets.right
            }
        }
        
        return CGSize(width: width, height: 44)
    }
    
    override func configure(cell: UICollectionViewCell, collectionView: UICollectionView, indexPath: NSIndexPath) {
        cell.contentView.backgroundColor = UIColor.redColor()
    }

}
