//
//  UITableViewController+Delegate.swift
//  FOCollectionsExamples
//
//  Created by Daniel Krofchick on 2015-11-11.
//  Copyright © 2015 Figure1. All rights reserved.
//

import UIKit

extension FOTableViewController {
    
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if clearCellInsets {
            cell.layoutMargins = UIEdgeInsets.zero
            cell.separatorInset = UIEdgeInsets.zero
        }
        
        // delay one cycle to allow cell to finish being created
        DispatchQueue.main.async(execute: {
            DispatchQueue.main.async(execute: {
                DispatchQueue.main.async(execute: {
                    [weak self] in
                    if let item = self?.dataSource.itemAtIndexPath(indexPath) {
                        item.operations += item.getResources(tableView, indexPath: indexPath)
                    }
                })
            })
        })
        
        delegateWithIndexPath(indexPath)?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        delegateWithSectionIndex(section)?.tableView?(tableView, willDisplayHeaderView: view, forSection: section)
    }
    
    open func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        delegateWithSectionIndex(section)?.tableView?(tableView, willDisplayFooterView: view, forSection: section)
    }
    
    open func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let item = dataSource.itemAtIndexPath(indexPath) {
            item.operations.forEach{$0.cancel()}
            item.operations.removeAll()
        }
        delegateWithIndexPath(indexPath)?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        delegateWithSectionIndex(section)?.tableView?(tableView, didEndDisplayingHeaderView: view, forSection: section)
    }
    
    open func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        delegateWithSectionIndex(section)?.tableView?(tableView, didEndDisplayingFooterView: view, forSection: section)
    }

    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let key = dataSource.keyForItemAtIndexPath(indexPath)
        
        if key != nil && cellSizeCache[key!] != nil {
            return cellSizeCache[key!]!
        } else if let value = delegateWithIndexPath(indexPath)?.tableView?(tableView, heightForRowAt: indexPath) {
            if key != nil {
                cellSizeCache[key!] = value
            }
            
            return value
        } else {
            return 0
        }
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let value = delegateWithSectionIndex(section)?.tableView?(tableView, heightForHeaderInSection: section) {
            return value
        } else {
            return 0
        }
    }
    
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let value = delegateWithSectionIndex(section)?.tableView?(tableView, heightForFooterInSection: section) {
            return value
        } else {
            return 0
        }
    }
    
    open func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        var result = UITableViewAutomaticDimension
        
        if let value = delegateWithIndexPath(indexPath)?.tableView?(tableView, estimatedHeightForRowAt: indexPath) {
            result = value
        }
        
        return result
    }
    
    open func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        var result = UITableViewAutomaticDimension
        
        if let value = delegateWithSectionIndex(section)?.tableView?(tableView, estimatedHeightForHeaderInSection: section) {
            result = value
        }
        
        return result
    }
    
    open func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        var result = UITableViewAutomaticDimension
        
        if let value = delegateWithSectionIndex(section)?.tableView?(tableView, estimatedHeightForFooterInSection: section) {
            result = value
        }
        
        return result
    }

    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return delegateWithSectionIndex(section)?.tableView?(tableView, viewForHeaderInSection: section)
    }

    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return delegateWithSectionIndex(section)?.tableView?(tableView, viewForFooterInSection: section)
    }

    open func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        delegateWithIndexPath(indexPath)?.tableView?(tableView, accessoryButtonTappedForRowWith: indexPath)
    }

    open func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if let value = delegateWithIndexPath(indexPath)?.tableView?(tableView, shouldHighlightRowAt: indexPath) {
            return value
        } else {
            return true
        }
    }
    
    open func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        delegateWithIndexPath(indexPath)?.tableView?(tableView, didHighlightRowAt: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        delegateWithIndexPath(indexPath)?.tableView?(tableView, didUnhighlightRowAt: indexPath)
    }

    open func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let configurator = delegateWithIndexPath(indexPath) {
            if configurator.responds(to: #selector(UITableViewDelegate.tableView(_:willSelectRowAt:))) {
                return configurator.tableView?(tableView, willSelectRowAt: indexPath)
            }
        }
        
        return indexPath
    }
    
    open func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        if let configurator = delegateWithIndexPath(indexPath) {
            if configurator.responds(to: #selector(UITableViewDelegate.tableView(_:willDeselectRowAt:))) {
                return configurator.tableView?(tableView, willDeselectRowAt: indexPath)
            }
        }
        
        return indexPath
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegateWithIndexPath(indexPath)?.tableView?(tableView, didSelectRowAt: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        delegateWithIndexPath(indexPath)?.tableView?(tableView, didDeselectRowAt: indexPath)
    }

    open func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if let value = delegateWithIndexPath(indexPath)?.tableView?(tableView, editingStyleForRowAt: indexPath) {
            return value
        } else {
            return .delete
        }
    }
    
    open func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        if let configurator = delegateWithIndexPath(indexPath) {
            if configurator.responds(to: #selector(UITableViewDelegate.tableView(_:titleForDeleteConfirmationButtonForRowAt:))) {
                return configurator.tableView?(tableView, titleForDeleteConfirmationButtonForRowAt: indexPath)
            }
        }
        
        return "Delete"
    }
    
    open func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if let configurator = delegateWithIndexPath(indexPath) {
            if configurator.responds(to: #selector(UITableViewDelegate.tableView(_:editActionsForRowAt:))) {
                return configurator.tableView?(tableView, editActionsForRowAt: indexPath)
            }
        }
        
        // Replace with proper default
        return nil
    }

    open func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        if let value = delegateWithIndexPath(indexPath)?.tableView?(tableView, shouldIndentWhileEditingRowAt: indexPath) {
            return value
        } else {
            return true
        }
    }
    
    open func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        delegateWithIndexPath(indexPath)?.tableView?(tableView, willBeginEditingRowAt: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        if let indexPath = indexPath {
            delegateWithIndexPath(indexPath)?.tableView?(tableView, didEndEditingRowAt: indexPath)
        }
    }

    /**
    override public func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
    }
    **/

    open func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        if let value = delegateWithIndexPath(indexPath)?.tableView?(tableView, indentationLevelForRowAt: indexPath) {
            return value
        } else {
            return 0
        }
    }
    
    open func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        if let value = delegateWithIndexPath(indexPath)?.tableView?(tableView, shouldShowMenuForRowAt: indexPath) {
            return value
        } else {
            return false
        }
    }
    
    open func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if let value = delegateWithIndexPath(indexPath)?.tableView?(tableView, canPerformAction: action, forRowAt: indexPath, withSender: sender) {
            return value
        } else {
            return false
        }
    }
    
    open func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        delegateWithIndexPath(indexPath)?.tableView?(tableView, performAction: action, forRowAt: indexPath, withSender: sender)
    }
    
    @available(iOS 9.0, *)
    open func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        if let value = delegateWithIndexPath(indexPath)?.tableView?(tableView, canFocusRowAt: indexPath) {
            return value
        } else {
            // Replace with proper default
            return true
        }
    }

    /**
    override public func tableView(tableView: UITableView, shouldUpdateFocusInContext context: UITableViewFocusUpdateContext) -> Bool {        
    }
    
    override public func tableView(tableView: UITableView, didUpdateFocusInContext context: UITableViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
    }
    
    override public func indexPathForPreferredFocusedViewInTableView(tableView: UITableView) -> NSIndexPath? {
    }
    **/
     
    //MARK:- utils
    
    // dequeueReusableCell results in infinite loop. Therefore keep our own sizing cache
    open func layoutCellForIndexPath(_ indexPath: IndexPath) -> UITableViewCell? {
        var cell: UITableViewCell? = nil
        
        if
            let item = dataSource.itemAtIndexPath(indexPath),
            let cellClass = item.cellClass,
            let key = NSStringFromClass(cellClass).components(separatedBy: ".").last
        {
            cell = layoutCellCache[key]
            
            if cell == nil && cellClass is UITableViewCell.Type {
                cell = (cellClass as! UITableViewCell.Type).init()
                layoutCellCache[key] = cell
            }
            
            cell?.separatorInset = tableView.separatorInset
            cell?.layoutMargins = tableView.layoutMargins
        }
        
        return cell
    }
    
    fileprivate func delegateWithIndexPath(_ indexPath: IndexPath) -> UITableViewDelegate? {
        return dataSource.itemAtIndexPath(indexPath)
    }
    
    fileprivate func delegateWithSectionIndex(_ sectionIndex: Int) -> UITableViewDelegate? {
        return dataSource.sectionAtIndex(sectionIndex)
    }
}
