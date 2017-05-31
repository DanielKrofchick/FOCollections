//
//  FOCollectionViewController+UIcollectionViewDelegateFlowLayout.swift
//  FOCollections
//
//  Created by Daniel Krofchick on 2015-11-08.
//  Copyright © 2015 Figure1. All rights reserved.
//

import UIKit

extension FOCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let key = dataSource.keyForItemAtIndexPath(indexPath)
        
        if key != nil && cellSizeCache[key!] != nil {
            return cellSizeCache[key!]!
        } else if let value = delegateWithIndexPath(indexPath)?.collectionView?(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath) {
            if key != nil {
                cellSizeCache[key!] = value
            }
            
            return value
        } else {
            return CGSize.zero
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if let value = delegateWithSectionIndex(section)?.collectionView?(collectionView, layout: collectionViewLayout, insetForSectionAt: section) {
            return value
        } else {
            return UIEdgeInsets.zero
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if let value = delegateWithSectionIndex(section)?.collectionView?(collectionView, layout: collectionViewLayout, minimumLineSpacingForSectionAt: section) {
            return value
        } else {
            return 0
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if let value = delegateWithSectionIndex(section)?.collectionView?(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAt: section) {
            return value
        } else {
            return 0
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if let value = delegateWithSectionIndex(section)?.collectionView?(collectionView, layout: collectionViewLayout, referenceSizeForHeaderInSection: section) {
            return value
        } else {
            return CGSize.zero
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if let value = delegateWithSectionIndex(section)?.collectionView?(collectionView, layout: collectionViewLayout, referenceSizeForFooterInSection: section) {
            return value
        } else {
            return CGSize.zero
        }
    }
    
    // MARK: - Utility
    
    public func layoutCellForIndexPath(_ indexPath: IndexPath) -> UICollectionViewCell? {
        var cell: UICollectionViewCell? = nil
        
        if
            let item = dataSource.itemAtIndexPath(indexPath),
            let cellClass = item.cellClass,
            let key = NSStringFromClass(cellClass).components(separatedBy: ".").last
        {
            cell = layoutCellCache[key]
            
            if cell == nil && cellClass is UICollectionViewCell.Type {
                cell = (cellClass as! UICollectionViewCell.Type).init()
                layoutCellCache[key] = cell
            }
        }
        
        return cell
    }
    
    fileprivate func delegateWithIndexPath(_ indexPath: IndexPath) -> UICollectionViewDelegateFlowLayout? {
        return dataSource.itemAtIndexPath(indexPath)
    }
    
    fileprivate func delegateWithSectionIndex(_ index: Int) -> UICollectionViewDelegateFlowLayout? {
        return dataSource.sectionAtIndex(index)
    }
}
