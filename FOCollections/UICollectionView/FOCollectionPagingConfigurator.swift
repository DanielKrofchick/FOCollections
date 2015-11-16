//
//  FOCollectionPagingConfigurator.swift
//  Figure1
//
//  Created by Daniel Krofchick on 2015-05-07.
//  Copyright (c) 2015 Movable Science. All rights reserved.
//

import UIKit

public class FOCollectionPagingConfigurator: FOCollectionConfigurator {

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var width = collectionView.frame.size.width
        
        if let collectionViewLayout = collectionViewLayout as? UICollectionViewFlowLayout, viewController = viewController as? UICollectionViewDelegateFlowLayout {
            if let sectionInsets = viewController.collectionView?(collectionView, layout: collectionViewLayout, insetForSectionAtIndex: indexPath.section) {
                width = collectionView.frame.size.width - sectionInsets.left - sectionInsets.right
            }
        }
        
        return CGSize(width: width, height: 44)
    }
    
    override public func configure(cell: UICollectionViewCell, collectionView: UICollectionView, indexPath: NSIndexPath) {
        cell.contentView.backgroundColor = UIColor.redColor()
    }
    
}
