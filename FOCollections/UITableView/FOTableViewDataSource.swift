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
    
    public func insertSections(sections: [FOTableSection], atIndexes indexes: NSIndexSet, tableView: UITableView, viewController: UIViewController) {
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
    
    public func insertItems(items: [FOTableItem], atIndexPaths indexPaths: [NSIndexPath], tableView: UITableView, viewController: UIViewController) {
        let (i, p) = privateInsertItems(items, atIndexPaths: indexPaths, tableView: tableView, viewController: viewController)
        
        // if items remain throw exception
        assert(i.count == 0, "unable to insert items \(i) at indexPaths \(p)")
        
        keyCache.removeAll(keepCapacity: true)
    }
    
    // Inserts items within current data range. Returns uninserted items.
    
    private func privateInsertItems(items: [FOTableItem], atIndexPaths indexPaths: [NSIndexPath], tableView: UITableView, viewController: UIViewController) -> ([FOTableItem], [NSIndexPath]) {
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
    
    public func deleteItemsAtIndexPaths(indexPaths: [NSIndexPath], tableView: UITableView) {
        for indexPath in indexPaths.sort({$0.item > $1.item}) {
            if let section = sectionAtIndex(indexPath.section) {
                section.items?.removeAtIndex(indexPath.item)
            }
        }
        
        keyCache.removeAll(keepCapacity: true)
    }
    
    public func appendItems(items: [FOTableItem], toSectionAtIndex sectionIndex: Int, tableView: UITableView, viewController: UIViewController) -> [NSIndexPath]? {
        var indexPaths: [NSIndexPath]? = nil
        
        if let section = sectionAtIndex(sectionIndex), var location = section.items?.count {
            if let viewController = viewController as? FOTableViewController {
                if section.pagingDirection == .Down && viewController.pagingIndexPath(section) != nil {
                    location -= 1
                }
            }
            
            indexPaths = NSIndexPath.indexPathsForItemsInRange(NSMakeRange(location, items.count), section: sectionIndex)
            
            if let indexPaths = indexPaths {
                insertItems(items, atIndexPaths: indexPaths, tableView: tableView, viewController: viewController)
            }
        }
        
        return indexPaths
    }
    
    public func prependItems(items: [FOTableItem], toSectionAtIndex sectionIndex: Int, tableView: UITableView, viewController: UIViewController) -> [NSIndexPath]? {
        var indexPaths: [NSIndexPath]? = nil
        
        if let section = sectionAtIndex(sectionIndex) {
            var location = 0
            
            if let viewController = viewController as? FOTableViewController {
                if section.pagingDirection == .Up && viewController.pagingIndexPath(section) != nil {
                    location += 1
                }
            }
            
            indexPaths = NSIndexPath.indexPathsForItemsInRange(NSMakeRange(location, items.count), section: sectionIndex)
            
            if let indexPaths = indexPaths {
                insertItems(items, atIndexPaths: indexPaths, tableView: tableView, viewController: viewController)
            }
        }
        
        return indexPaths
    }
    
    public func clearAllItems(tableView: UITableView) -> NSIndexSet? {
        let indexes = NSIndexSet(indexesInRange: NSMakeRange(0, numberOfSectionsInTableView(tableView)))
        deleteSectionsAtIndexes(indexes, tableView: tableView)
        
        return indexes.count == 0 ? nil : indexes
    }
    
    public func setPagingState(pagingState: PagingState, sectionIndex: Int, tableView: UITableView, viewController: UIViewController) -> NSIndexPath? {
        var pagingIndexPath: NSIndexPath? = nil
        
        if let section = sectionAtIndex(sectionIndex), viewController = viewController as? FOTableViewController {
            pagingIndexPath = viewController.pagingIndexPath(section)
            
            if section.pagingState == pagingState {
                pagingIndexPath = nil
            } else if pagingState == .Paging && pagingIndexPath == nil {
                // ADD
                if section.pagingDirection == .Down {
                    if let p = lastIndexPathForSectionIndex(sectionIndex) {
                        pagingIndexPath = NSIndexPath(forRow: p.row + 1, inSection: p.section)
                    }
                } else if section.pagingDirection == .Up {
                    pagingIndexPath = NSIndexPath(forItem: 0, inSection: 0)
                }
                
                if let pagingIndexPath = pagingIndexPath {
                    let pagingItem = viewController.pagingItemForSection(section)
                    insertItems([pagingItem], atIndexPaths: [pagingIndexPath], tableView: tableView, viewController: viewController)
                }
            } else if (pagingState == .NotPaging || pagingState == .Disabled || pagingState == .Finished) {
                // REMOVE
                if let pagingIndexPath = pagingIndexPath {
                    deleteItemsAtIndexPaths([pagingIndexPath], tableView: tableView)
                }
            } else {
                pagingIndexPath = nil
            }
            
            section.pagingState = pagingState
        }
        
        return pagingIndexPath
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

extension FOTableViewDataSource: SequenceType {

    public typealias Generator = AnyGenerator<FOTableItem>
    
    public func generate() -> Generator {
        var index = Int(0)
        return AnyGenerator { () -> FOTableItem? in
            let item = self.itemAtIndex(index)
            index += 1
            return item
        }
    }
    
    public func itemAtIndex(index: Int) -> FOTableItem? {
        var i = 0
        
        for section in sections {
            if i <= index {
                if let items = section.items {
                    if let item = items.safe(index - i) {
                        return item
                    } else {
                        i += items.count
                    }
                }
            }
        }
        
        return nil
    }
    
    public func indexPathForIndex(index: Int) -> NSIndexPath? {
        var i = 0
        
        for (s, section) in sections.enumerate() {
            if i <= index {
                if let items = section.items {
                    if let _ = items.safe(index - i) {
                        return NSIndexPath(forRow: index - i, inSection: s)
                    } else {
                        i += items.count
                    }
                }
            }
        }
        
        return nil
    }
    
    public func indexForIndexPath(indexPath: NSIndexPath) -> Int? {
        var i = 0
        
        for (index, section) in sections.enumerate() {
            if let items = section.items {
                if index < indexPath.section {
                    i += items.count
                } else if index == indexPath.section && items.count > indexPath.row {
                    return i + indexPath.row
                } else {
                    return nil
                }
            }
        }
        
        return nil
    }
    
    public func previousIndexPath(indexPath: NSIndexPath) -> NSIndexPath? {
        if let index = indexForIndexPath(indexPath) {
            return indexPathForIndex(index - 1)
        }
        
        return nil
    }

    public func nextIndexPath(indexPath: NSIndexPath) -> NSIndexPath? {
        if let index = indexForIndexPath(indexPath) {
            return indexPathForIndex(index + 1)
        }
        
        return nil
    }
    
}

