//
//  FOCollectionViewController+UIcollectionViewDelegateFlowLayout.swift
//  FOCollections
//
//  Created by Daniel Krofchick on 2015-11-08.
//  Copyright © 2015 Figure1. All rights reserved.
//

import UIKit

extension FOCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let key = dataSource.keyForItemAtIndexPath(indexPath)
        
        if key != nil && cellSizeCache[key!] != nil {
            return cellSizeCache[key!]!
        } else if let value = delegateWithIndexPath(indexPath)?.collectionView?(collectionView, layout: collectionViewLayout, sizeForItemAtIndexPath: indexPath) {
            if key != nil {
                cellSizeCache[key!] = value
            }
            
            return value
        } else {
            return CGSizeZero
        }
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        if let value = delegateWithSectionIndex(section)?.collectionView?(collectionView, layout: collectionViewLayout, insetForSectionAtIndex: section) {
            return value
        } else {
            return UIEdgeInsetsZero
        }
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        if let value = delegateWithSectionIndex(section)?.collectionView?(collectionView, layout: collectionViewLayout, minimumLineSpacingForSectionAtIndex: section) {
            return value
        } else {
            return 0
        }
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        if let value = delegateWithSectionIndex(section)?.collectionView?(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAtIndex: section) {
            return value
        } else {
            return 0
        }
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if let value = delegateWithSectionIndex(section)?.collectionView?(collectionView, layout: collectionViewLayout, referenceSizeForHeaderInSection: section) {
            return value
        } else {
            return CGSizeZero
        }
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if let value = delegateWithSectionIndex(section)?.collectionView?(collectionView, layout: collectionViewLayout, referenceSizeForFooterInSection: section) {
            return value
        } else {
            return CGSizeZero
        }
    }
    
    // MARK: - Utility
        
    func layoutCellForIndexPath(indexPath: NSIndexPath) -> UICollectionViewCell? {
        var cell: UICollectionViewCell? = nil
        
        if let item = dataSource.itemAtIndexPath(indexPath) {
            if let cellClass = item.cellClass {
                if let key = NSStringFromClass(cellClass).componentsSeparatedByString(".").last {
                    cell = layoutCellCache[key]
                    
                    if cell == nil && cellClass is UICollectionViewCell.Type {
                        cell = (cellClass as! UICollectionViewCell.Type).init()
                        layoutCellCache[key] = cell
                    }
                }
            }
        }
        
        return cell
    }
    
    private func delegateWithIndexPath(indexPath: NSIndexPath) -> UICollectionViewDelegateFlowLayout? {
        return dataSource.itemAtIndexPath(indexPath) as? UICollectionViewDelegateFlowLayout
    }
    
    private func delegateWithSectionIndex(index: Int) -> UICollectionViewDelegateFlowLayout? {
        return dataSource.sectionAtIndex(index) as? UICollectionViewDelegateFlowLayout
    }
}
