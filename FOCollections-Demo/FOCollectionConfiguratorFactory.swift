//
//  FOEmptyConfigurator.swift
//  FOCollectionsExamples
//
//  Created by Daniel Krofchick on 2015-11-09.
//  Copyright © 2015 Figure1. All rights reserved.
//

import Foundation
import UIKit
import FOCollections

class FOCollectionItemConfigurator: FOCollectionConfigurator {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if let width = item?.widthForCollectionView(collectionView, indexPath: indexPath) {
            return CGSize(width: width, height: width)
        } else {
            return CGSize(width: 50.0, height: 50.0)
        }
    }
    
    override func configure(cell: UICollectionViewCell, collectionView: UICollectionView, indexPath: NSIndexPath) {
        cell.contentView.backgroundColor = UIColor.blueColor()
    }
    
}

class FOCollectionSectionConfigurator: FOCollectionConfigurator {
    
    var edgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    var minimumLineSpacing = CGFloat(5)
    var minimumInteritemSpacing = CGFloat(5)
    
    override init() {
        super.init()
        
        item = FOCollectionItem()
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return edgeInsets
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return minimumLineSpacing
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return minimumInteritemSpacing
    }
    
}
