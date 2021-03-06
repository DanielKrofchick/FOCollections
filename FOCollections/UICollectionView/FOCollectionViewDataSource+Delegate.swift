//
//  FOCollectionViewDataSource+Delegate.swift
//  FOCollectionsExamples
//
//  Created by Daniel Krofchick on 2015-11-11.
//  Copyright © 2015 Figure 1 Inc. All rights reserved.
//

import UIKit

extension FOCollectionViewDataSource: UICollectionViewDataSource {
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sectionAtIndex(section)?.items?.count ?? 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell? = nil
        
        if let item = itemAtIndexPath(indexPath) {
            if let reuseIdentifier = item.reuseIdentifier {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
                item.configure(cell!, collectionView: collectionView, indexPath: indexPath)
            }
        }
        
        return cell == nil ? UICollectionViewCell() : cell!
    }
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count 
    }
}
