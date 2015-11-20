//
//  FOPagingCollectionItem.swift
//  FOCollections
//
//  Created by Xiao Ma on 2015-11-20.
//  Copyright © 2015 Figure1. All rights reserved.
//

import UIKit

public class FOCollectionPagingItem: FOCollectionItem {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var width = collectionView.frame.size.width
        
        if let collectionViewLayout = collectionViewLayout as? UICollectionViewFlowLayout, viewController = configurator?.viewController as? UICollectionViewDelegateFlowLayout {
            if let sectionInsets = viewController.collectionView?(collectionView, layout: collectionViewLayout, insetForSectionAtIndex: indexPath.section) {
                width = collectionView.frame.size.width - sectionInsets.left - sectionInsets.right
            }
        }
        
        return CGSize(width: width, height: 44)
    }
}
