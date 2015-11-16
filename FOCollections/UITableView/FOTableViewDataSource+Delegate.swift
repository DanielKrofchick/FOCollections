//
//  FOTableViewDataSource+Delegate.swift
//  FOCollectionsExamples
//
//  Created by Daniel Krofchick on 2015-11-11.
//  Copyright © 2015 Figure1. All rights reserved.
//

import UIKit

extension FOTableViewDataSource: UITableViewDataSource {
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionAtIndex(section)?.items?.count ?? 0
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = nil
        
        if let item = itemAtIndexPath(indexPath) {
            if let reuseIdentifier = item.reuseIdentifier {
                cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
                item.configurator?.configure(cell!, tableView: tableView, indexPath: indexPath)
                
                // delay one cycle to allow cell to finish being created
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                        item.configurator?.getExtras(tableView, indexPath: indexPath)
                    })
                })
            }
        }
        
        return cell == nil ? UITableViewCell() : cell!
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count ?? 1
    }
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return configuratorForSection(section)?.tableView?(tableView, titleForHeaderInSection: section)
    }

    public func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return configuratorForSection(section)?.tableView?(tableView, titleForFooterInSection: section)
    }

    public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let value = configurator(indexPath)?.tableView?(tableView, canEditRowAtIndexPath: indexPath) {
            return value
        } else {
            return true
        }
    }

    public func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let value = configurator(indexPath)?.tableView?(tableView, canMoveRowAtIndexPath: indexPath) {
            return value
        } else {
            return false
        }
    }

    /**
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
    }
    **/

    public func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        configurator(indexPath)?.tableView?(tableView, commitEditingStyle: editingStyle, forRowAtIndexPath: indexPath)
    }
    
    /**
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
    }
    **/
    
}
