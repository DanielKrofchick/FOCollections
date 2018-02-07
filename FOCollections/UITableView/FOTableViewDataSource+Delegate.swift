//
//  FOTableViewDataSource+Delegate.swift
//  FOCollectionsExamples
//
//  Created by Daniel Krofchick on 2015-11-11.
//  Copyright © 2015 Figure 1 Inc. All rights reserved.
//

import UIKit

extension FOTableViewDataSource: UITableViewDataSource {
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionAtIndex(section)?.items?.count ?? 0
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = nil
        
        if let item = itemAtIndexPath(indexPath) {
            if let reuseIdentifier = item.reuseIdentifier {
                cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
                item.configure(cell!, tableView: tableView, indexPath: indexPath)
            }
        }
        
        return cell == nil ? UITableViewCell() : cell!
    }
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return delegateWithSectionIndex(section)?.tableView?(tableView, titleForHeaderInSection: section)
    }

    open func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return delegateWithSectionIndex(section)?.tableView?(tableView, titleForFooterInSection: section)
    }

    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let value = delegateWithIndexPath(indexPath)?.tableView?(tableView, canEditRowAt: indexPath) {
            return value
        } else {
            return true
        }
    }

    open func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if let value = delegateWithIndexPath(indexPath)?.tableView?(tableView, canMoveRowAt: indexPath) {
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

    open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        delegateWithIndexPath(indexPath)?.tableView?(tableView, commit: editingStyle, forRowAt: indexPath)
    }
    
    /**
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
    }
    **/
    
     //MARK:- utils
    fileprivate func delegateWithIndexPath(_ indexPath: IndexPath) -> UITableViewDataSource? {
        return itemAtIndexPath(indexPath)
    }
    
    fileprivate func delegateWithSectionIndex(_ sectionIndex: Int) -> UITableViewDataSource? {
        return sectionAtIndex(sectionIndex) as? UITableViewDataSource
    }
}
