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
                item.configure(cell!, tableView: tableView, indexPath: indexPath)
            }
        }
        
        return cell == nil ? UITableViewCell() : cell!
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count ?? 1
    }
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return delegateWithSectionIndex(section)?.tableView?(tableView, titleForHeaderInSection: section)
    }

    public func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return delegateWithSectionIndex(section)?.tableView?(tableView, titleForFooterInSection: section)
    }

    public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let value = delegateWithIndexPath(indexPath)?.tableView?(tableView, canEditRowAtIndexPath: indexPath) {
            return value
        } else {
            return true
        }
    }

    public func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let value = delegateWithIndexPath(indexPath)?.tableView?(tableView, canMoveRowAtIndexPath: indexPath) {
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
        delegateWithIndexPath(indexPath)?.tableView?(tableView, commitEditingStyle: editingStyle, forRowAtIndexPath: indexPath)
    }
    
    /**
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
    }
    **/
    
     //MARK:- utils
    private func delegateWithIndexPath(indexPath: NSIndexPath) -> UITableViewDataSource? {
        return itemAtIndexPath(indexPath) as? UITableViewDataSource
    }
    
    private func delegateWithSectionIndex(sectionIndex: Int) -> UITableViewDataSource? {
        return sectionAtIndex(sectionIndex) as? UITableViewDataSource
    }
}
