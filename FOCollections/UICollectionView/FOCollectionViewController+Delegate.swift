//
//  FOCollectionViewController+UICollectionViewDelegate.swift
//  FOCollections
//
//  Created by Daniel Krofchick on 2015-11-08.
//  Copyright © 2015 Figure1. All rights reserved.
//

// MARK: UICollectionViewDelegate - Forwarding

import UIKit

extension FOCollectionViewController  {
    
    fileprivate func delegateWithIndexPath(_ indexPath: IndexPath) -> UICollectionViewDelegate? {
        return dataSource.itemAtIndexPath(indexPath)
    }
    
    override open func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        if let value = delegateWithIndexPath(indexPath)?.collectionView?(collectionView, shouldHighlightItemAt: indexPath) {
            return value
        } else {
            return true
        }
    }
    
    override open func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        delegateWithIndexPath(indexPath)?.collectionView?(collectionView, didHighlightItemAt: indexPath)
    }
    
    override open func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        delegateWithIndexPath(indexPath)?.collectionView?(collectionView, didUnhighlightItemAt: indexPath)
    }
    
    override open func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let value = delegateWithIndexPath(indexPath)?.collectionView?(collectionView, shouldSelectItemAt: indexPath) {
            return value
        } else {
            return true
        }
    }
    
    override open func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        if let value = delegateWithIndexPath(indexPath)?.collectionView?(collectionView, shouldDeselectItemAt: indexPath) {
            return value
        } else {
            return true
        }
    }
    
    override open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegateWithIndexPath(indexPath)?.collectionView?(collectionView, didSelectItemAt: indexPath)
    }
    
    override open func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        delegateWithIndexPath(indexPath)?.collectionView?(collectionView, didDeselectItemAt: indexPath)
    }
    
    override open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // delayopenone cycle to allow cell to finish being created
        DispatchQueue.main.async(execute: {
            DispatchQueue.main.async(execute: {
                DispatchQueue.main.async(execute: {
                    [weak self] in
                    if let item = self?.dataSource.itemAtIndexPath(indexPath) {
                        item.operations += item.getResources(collectionView, indexPath: indexPath)
                    }
                })
            })
        })
        
        delegateWithIndexPath(indexPath)?.collectionView?(collectionView, willDisplay: cell, forItemAt: indexPath)
    }
    
    override open func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        delegateWithIndexPath(indexPath)?.collectionView?(collectionView, willDisplaySupplementaryView: view, forElementKind: elementKind, at: indexPath)
    }
    
    override open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let item = dataSource.itemAtIndexPath(indexPath) {
            item.operations.forEach{$0.cancel()}
            item.operations.removeAll()
        }
        delegateWithIndexPath(indexPath)?.collectionView?(collectionView, didEndDisplaying: cell, forItemAt: indexPath)
    }
    
    override open func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        delegateWithIndexPath(indexPath)?.collectionView?(collectionView, didEndDisplayingSupplementaryView: view, forElementOfKind: elementKind, at: indexPath)
    }
    
    override open func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        if let value = delegateWithIndexPath(indexPath)?.collectionView?(collectionView, shouldShowMenuForItemAt: indexPath) {
            return value
        } else {
            return false
        }
    }
    
    override open func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if let value = delegateWithIndexPath(indexPath)?.collectionView?(collectionView, canPerformAction: action, forItemAt: indexPath, withSender: sender) {
            return value
        } else {
            return false
        }
    }
    
    override open func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        delegateWithIndexPath(indexPath)?.collectionView?(collectionView, performAction: action, forItemAt: indexPath, withSender: sender)
    }
    
    /**
    override public func collectionView(collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout {
    }
    **/

    @available(iOS 9.0, *)
    override open func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        if let value = delegateWithIndexPath(indexPath)?.collectionView?(collectionView, canFocusItemAt: indexPath) {
            return value
        } else {
            return true
        }
    }
    
    /**
    override public func collectionView(collectionView: UICollectionView, shouldUpdateFocusInContext context: UICollectionViewFocusUpdateContext) -> Bool {
    }
    
    override public func collectionView(collectionView: UICollectionView, didUpdateFocusInContext context: UICollectionViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
    }
    
    override public func indexPathForPreferredFocusedViewInCollectionView(collectionView: UICollectionView) -> NSIndexPath? {
    }
    
    override public func collectionView(collectionView: UICollectionView, targetIndexPathForMoveFromItemAtIndexPath originalIndexPath: NSIndexPath, toProposedIndexPath proposedIndexPath: NSIndexPath) -> NSIndexPath {
    }
    
    override public func collectionView(collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
    }
    **/
    
}
