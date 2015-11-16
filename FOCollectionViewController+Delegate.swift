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
    
    override public func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let value = configurator(indexPath)?.collectionView?(collectionView, shouldHighlightItemAtIndexPath: indexPath) {
            return value
        } else {
            return true
        }
    }
    
    override public func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        configurator(indexPath)?.collectionView?(collectionView, didHighlightItemAtIndexPath: indexPath)
    }
    
    override public func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        configurator(indexPath)?.collectionView?(collectionView, didUnhighlightItemAtIndexPath: indexPath)
    }
    
    override public func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let value = configurator(indexPath)?.collectionView?(collectionView, shouldSelectItemAtIndexPath: indexPath) {
            return value
        } else {
            return true
        }
    }
    
    override public func collectionView(collectionView: UICollectionView, shouldDeselectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let value = configurator(indexPath)?.collectionView?(collectionView, shouldDeselectItemAtIndexPath: indexPath) {
            return value
        } else {
            return true
        }
    }
    
    override public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        configurator(indexPath)?.collectionView?(collectionView, didSelectItemAtIndexPath: indexPath)
    }
    
    override public func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        configurator(indexPath)?.collectionView?(collectionView, didDeselectItemAtIndexPath: indexPath)
    }
    
    override public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        configurator(indexPath)?.collectionView?(collectionView, willDisplayCell: cell, forItemAtIndexPath: indexPath)
    }
    
    override public func collectionView(collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, atIndexPath indexPath: NSIndexPath) {
        configurator(indexPath)?.collectionView?(collectionView, willDisplaySupplementaryView: view, forElementKind: elementKind, atIndexPath: indexPath)
    }
    
    override public func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        configurator(indexPath)?.collectionView?(collectionView, didEndDisplayingCell: cell, forItemAtIndexPath: indexPath)
    }
    
    override public func collectionView(collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, atIndexPath indexPath: NSIndexPath) {
        configurator(indexPath)?.collectionView?(collectionView, didEndDisplayingSupplementaryView: view, forElementOfKind: elementKind, atIndexPath: indexPath)
    }
    
    override public func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let value = configurator(indexPath)?.collectionView?(collectionView, shouldShowMenuForItemAtIndexPath: indexPath) {
            return value
        } else {
            return false
        }
    }
    
    override public func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        if let value = configurator(indexPath)?.collectionView?(collectionView, canPerformAction: action, forItemAtIndexPath: indexPath, withSender: sender) {
            return value
        } else {
            return false
        }
    }
    
    override public func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
        configurator(indexPath)?.collectionView?(collectionView, performAction: action, forItemAtIndexPath: indexPath, withSender: sender)
    }
    
    /**
    override public func collectionView(collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout {
    }
    **/

    override public func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let value = configurator(indexPath)?.collectionView?(collectionView, canFocusItemAtIndexPath: indexPath) {
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