//
//  FOTableViewDataSource.swift
//  Figure1
//
//  Created by Daniel Krofchick on 2015-04-23.
//  Copyright (c) 2015 Movable Science. All rights reserved.
//

import UIKit

public class FOTableViewDataSource: NSObject {
    
    private(set) var sections = [FOTableSection]()
    private var keyCache = [NSIndexPath: String]()
    
    // MARK: Modification
    
    public func insertSections(sections: [FOTableSection], atIndexes indexes: NSIndexSet, tableView: UITableView, viewController: UIViewController? = nil) {
        indexes.enumerateIndexesUsingBlock { (index, stop) -> Void in
            if let section = sections.safe(index) {
                section.linkItems(viewController)
                self.sections.insert(section, atIndex: index)
                self.registerClassesForItems(section.items, tableView: tableView)
                self.keyCache.removeAll(keepCapacity: true)
            }
        }
    }
    
    public func deleteSectionsAtIndexes(indexes: NSIndexSet, tableView: UITableView) {
        indexes.enumerateIndexesWithOptions(NSEnumerationOptions.Reverse) { (index, stop) -> Void in
            self.sections.removeAtIndex(index)
            self.keyCache.removeAll(keepCapacity: true)
        }
    }
    
    public func insertItems(items: [FOTableItem], atIndexPaths indexPaths: [NSIndexPath], tableView: UITableView, viewController: UIViewController? = nil) {
        // sort decreasing
        var paired = FOPairedIndexPath.pairedIndexPaths(items, indexPaths: indexPaths).sort{$0 > $1}
        var (i, p) = FOPairedIndexPath.unpairedIndexPaths(paired)
        
        // insert items within current range, returns out-of-range items
        (i, p) = privateInsertItems(i, atIndexPaths: p, tableView: tableView, viewController: viewController)
        
        // sort increasing
        paired = FOPairedIndexPath.pairedIndexPaths(i, indexPaths: p).sort{$0 < $1}
        (i, p) = FOPairedIndexPath.unpairedIndexPaths(paired)
        
        // insert again
        (i, p) = privateInsertItems(i, atIndexPaths: p, tableView: tableView, viewController: viewController)
        
        // if items remain throw exception
        assert(i.count == 0, "unable to insert items \(i) at indexPaths \(p)")
        
        keyCache.removeAll(keepCapacity: true)
    }
    
    // Inserts items within current data range. Returns uninserted items.
    
    private func privateInsertItems(items: [FOTableItem], atIndexPaths indexPaths: [NSIndexPath], tableView: UITableView, viewController: UIViewController? = nil) -> ([FOTableItem], [NSIndexPath]) {
        var unsafeItems = [FOTableItem]()
        var unsafeIndexPaths = [NSIndexPath]()
        
        for (index, indexPath) in indexPaths.enumerate() {
            if let section = sectionAtIndex(indexPath.section) {
                if let item = items.safe(index), count = section.items?.count {
                    if indexPath.row <= count {
                        item.link(section, viewController: viewController)
                        section.items?.insert(item, atIndex: indexPath.row)
                        registerClassesForItems(items, tableView: tableView)
                    } else {
                        unsafeItems.append(item)
                        unsafeIndexPaths.append(indexPath)
                    }
                }
            }
        }
        
        return (unsafeItems, unsafeIndexPaths)
    }
    
    public func deleteItemsAtIndexPaths(var indexPaths: [NSIndexPath], tableView: UITableView) {
        indexPaths.sortInPlace{$0.item > $1.item}
        
        for indexPath in indexPaths {
            if let section = sectionAtIndex(indexPath.section) {
                section.items?.removeAtIndex(indexPath.item)
            }
        }
        
        keyCache.removeAll(keepCapacity: true)
    }
    
    private func registerClassesForSections(sections: [FOTableSection]?, tableView: UITableView) {
        guard sections != nil
            else {return}
        
        for section in sections! {
            if let items = section.items {
                self.registerClassesForItems(items, tableView: tableView)
            }
        }
    }
    
    private func registerClassesForItems(items: [FOTableItem]?, tableView: UITableView) {
        guard items != nil
            else {return}
        
        for item in items! {
            if let cellClass = item.cellClass, reuseIdentifier = item.reuseIdentifier {
                tableView.registerClass(cellClass, forCellReuseIdentifier: reuseIdentifier)
            }
        }
    }
    
    // MARK: - PAGING
    
    func sectionsForPagingState(pagingState: PagingState) -> NSIndexSet {
        let result = NSMutableIndexSet()
        
        for (index, section) in sections.enumerate() {
            if section.pagingState == pagingState {
                result.addIndex(index)
            }
        }
        
        return result
    }
    
    func lastIndexPathForSectionIndex(section: Int) -> NSIndexPath? {
        if let items = sectionAtIndex(section)?.items {
            return NSIndexPath(forItem: items.count - 1, inSection: section)
        } else {
            return nil
        }
    }
    
    func afterLastIndexPathForSectionIndex(section: Int) -> NSIndexPath? {
        if let lastIndexPath = lastIndexPathForSectionIndex(section) {
            return NSIndexPath(forItem: lastIndexPath.item + 1, inSection: lastIndexPath.section)
        } else {
            return nil
        }
    }
    
    // MARK: - Lookup    
    func keyForItemAtIndexPath(indexPath: NSIndexPath) -> String? {
        if let key = keyCache[indexPath] {
            return key
        } else if let item = itemAtIndexPath(indexPath) {
            let key = "\(item.identifier)-\(indexPath.section)-\(indexPath.row)"
            keyCache[indexPath] = key
            return key
        } else {
            return nil
        }
    }
    
    public func sectionAtIndex(index: NSInteger) -> FOTableSection? {
        return sections.safe(index)
    }
    
    public func itemAtIndexPath(indexPath: NSIndexPath) -> FOTableItem? {
        return sectionAtIndex(indexPath.section)?.itemAtIndex(indexPath.row)
    }
    
    public func dataAtIndexPath(indexPath: NSIndexPath) -> AnyObject? {
        return itemAtIndexPath(indexPath)?.data
    }
    
    public func indexesForSection(section: FOTableSection) -> NSIndexSet {
        let indexSet = NSMutableIndexSet()
        
        for (index, s) in sections.enumerate() {
            if section == s {
                indexSet.addIndex(index)
            }
        }
        
        return indexSet
    }
    
    public func indexPathsForItem(item: FOTableItem) -> [NSIndexPath] {
        var indexPaths = [NSIndexPath]()
        
        for (sectionIndex, section) in sections.enumerate() {
            indexPaths.appendContentsOf(section.indexPathsForItem(item, section: sectionIndex))
        }
        
        return indexPaths
    }
    
    public func indexPathsForData(data: AnyObject) -> [NSIndexPath]? {
        var indexPaths = [NSIndexPath]()
        
        for (sectionIndex, section) in sections.enumerate() {
            indexPaths.appendContentsOf(section.indexPathsForData(data, section: sectionIndex))
        }
        
        return indexPaths
    }
    
    public func cellsForItem(item: FOTableItem, tableView: UITableView) -> [UITableViewCell] {
        var cells = [UITableViewCell]()
        
        for cell in tableView.visibleCells {
            if let indexPath = tableView.indexPathForCell(cell ) {
                if let foundItem = itemAtIndexPath(indexPath) {
                    if item == foundItem {
                        cells.append(cell)
                    }
                }
            }
        }
        
        return cells
    }
    
}


