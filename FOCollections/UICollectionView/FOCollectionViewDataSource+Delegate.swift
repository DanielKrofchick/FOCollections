//
//  FOCollectionViewDataSource+Delegate.swift
//  FOCollectionsExamples
//
//  Created by Daniel Krofchick on 2015-11-11.
//  Copyright © 2015 Figure1. All rights reserved.
//

import UIKit

extension FOCollectionViewDataSource: UICollectionViewDataSource {
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sectionAtIndex(section)?.items?.count ?? 0
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell? = nil
        
        if let item = itemAtIndexPath(indexPath) {
            if let reuseIdentifier = item.reuseIdentifier {
                cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
                item.configure(cell!, collectionView: collectionView, indexPath: indexPath)
            }
        }
        
        return cell == nil ? UICollectionViewCell() : cell!
    }
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return sections.count ?? 1
    }

    /**
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    }

    func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    }

    func collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
    }
    **/
    
}
