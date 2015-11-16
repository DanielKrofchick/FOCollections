//
//  UITableViewController+Delegate.swift
//  FOCollectionsExamples
//
//  Created by Daniel Krofchick on 2015-11-11.
//  Copyright © 2015 Figure1. All rights reserved.
//

import UIKit

extension FOTableViewController {
    
    override public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        configurator(indexPath)?.tableView?(tableView, willDisplayCell: cell, forRowAtIndexPath: indexPath)
    }
    
    override public func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        configuratorForSection(section)?.tableView?(tableView, willDisplayHeaderView: view, forSection: section)
    }
    
    override public func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        configuratorForSection(section)?.tableView?(tableView, willDisplayFooterView: view, forSection: section)
    }
    
    override public func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        configurator(indexPath)?.tableView?(tableView, didEndDisplayingCell: cell, forRowAtIndexPath: indexPath)
    }
    
    override public func tableView(tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        configuratorForSection(section)?.tableView?(tableView, didEndDisplayingHeaderView: view, forSection: section)
    }
    
    override public func tableView(tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        configuratorForSection(section)?.tableView?(tableView, didEndDisplayingFooterView: view, forSection: section)
    }

    override public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let value = configurator(indexPath)?.tableView?(tableView, heightForRowAtIndexPath: indexPath) {
            return value
        } else {
            return 0
        }
    }
    
    override public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let value = configuratorForSection(section)?.tableView?(tableView, heightForHeaderInSection: section) {
            return value
        } else {
            return 0
        }
    }
    
    override public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let value = configuratorForSection(section)?.tableView?(tableView, heightForFooterInSection: section) {
            return value
        } else {
            return 0
        }
    }

    override public func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let value = configurator(indexPath)?.tableView?(tableView, estimatedHeightForRowAtIndexPath: indexPath) {
            return value
        } else if let value = configurator(indexPath)?.tableView?(tableView, heightForRowAtIndexPath: indexPath) {
            return value
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    override public func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if let value = configuratorForSection(section)?.tableView?(tableView, heightForHeaderInSection: section) {
            return value
        } else if let value = configuratorForSection(section)?.tableView?(tableView, estimatedHeightForHeaderInSection: section) {
            return value
        } else {
            return 0
        }
    }
    
    override public func tableView(tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        if let value = configuratorForSection(section)?.tableView?(tableView, heightForFooterInSection: section) {
            return value
        } else if let value = configuratorForSection(section)?.tableView?(tableView, estimatedHeightForFooterInSection: section) {
            return value
        } else {
            return 0
        }
    }

    override public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return configuratorForSection(section)?.tableView?(tableView, viewForHeaderInSection: section)
    }

    override public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return configuratorForSection(section)?.tableView?(tableView, viewForFooterInSection: section)
    }

    override public func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        configurator(indexPath)?.tableView?(tableView, accessoryButtonTappedForRowWithIndexPath: indexPath)
    }

    override public func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let value = configurator(indexPath)?.tableView?(tableView, shouldHighlightRowAtIndexPath: indexPath) {
            return value
        } else {
            return true
        }
    }
    
    override public func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        configurator(indexPath)?.tableView?(tableView, didHighlightRowAtIndexPath: indexPath)
    }
    
    override public func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        configurator(indexPath)?.tableView?(tableView, didUnhighlightRowAtIndexPath: indexPath)
    }

    override public func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if let configurator = configurator(indexPath) {
            if configurator.respondsToSelector(Selector("tableView:willSelectRowAtIndexPath:")) {
                return configurator.tableView?(tableView, willSelectRowAtIndexPath: indexPath)
            }
        }
        
        return indexPath
    }
    
    override public func tableView(tableView: UITableView, willDeselectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if let configurator = configurator(indexPath) {
            if configurator.respondsToSelector(Selector("tableView:willDeselectRowAtIndexPath:")) {
                return configurator.tableView?(tableView, willDeselectRowAtIndexPath: indexPath)
            }
        }
        
        return indexPath
    }
    
    override public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        configurator(indexPath)?.tableView?(tableView, didSelectRowAtIndexPath: indexPath)
    }
    
    override public func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        configurator(indexPath)?.tableView?(tableView, didDeselectRowAtIndexPath: indexPath)
    }

    override public func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if let value = configurator(indexPath)?.tableView?(tableView, editingStyleForRowAtIndexPath: indexPath) {
            return value
        } else {
            return .Delete
        }
    }
    
    override public func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        if let configurator = configurator(indexPath) {
            if configurator.respondsToSelector(Selector("tableView:titleForDeleteConfirmationButtonForRowAtIndexPath:")) {
                return configurator.tableView?(tableView, titleForDeleteConfirmationButtonForRowAtIndexPath: indexPath)
            }
        }
        
        return "Delete"
    }
    
    override public func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        if let configurator = configurator(indexPath) {
            if configurator.respondsToSelector(Selector("tableView:editActionsForRowAtIndexPath:")) {
                return configurator.tableView?(tableView, editActionsForRowAtIndexPath: indexPath)
            }
        }
        
        // Replace with proper default
        return nil
    }

    override public func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let value = configurator(indexPath)?.tableView?(tableView, shouldIndentWhileEditingRowAtIndexPath: indexPath) {
            return value
        } else {
            return true
        }
    }
    
    override public func tableView(tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: NSIndexPath) {
        configurator(indexPath)?.tableView?(tableView, willBeginEditingRowAtIndexPath: indexPath)
    }
    
    override public func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath) {
        configurator(indexPath)?.tableView?(tableView, didEndEditingRowAtIndexPath: indexPath)
    }

    /**
    override public func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
    }
    **/

    override public func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        if let value = configurator(indexPath)?.tableView?(tableView, indentationLevelForRowAtIndexPath: indexPath) {
            return value
        } else {
            return 0
        }
    }
    
    override public func tableView(tableView: UITableView, shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let value = configurator(indexPath)?.tableView?(tableView, shouldShowMenuForRowAtIndexPath: indexPath) {
            return value
        } else {
            return false
        }
    }
    
    override public func tableView(tableView: UITableView, canPerformAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        if let value = configurator(indexPath)?.tableView?(tableView, canPerformAction: action, forRowAtIndexPath: indexPath, withSender: sender) {
            return value
        } else {
            return false
        }
    }
    
    override public func tableView(tableView: UITableView, performAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
        configurator(indexPath)?.tableView?(tableView, performAction: action, forRowAtIndexPath: indexPath, withSender: sender)
    }
    
    override public func tableView(tableView: UITableView, canFocusRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let value = configurator(indexPath)?.tableView?(tableView, canFocusRowAtIndexPath: indexPath) {
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

}
