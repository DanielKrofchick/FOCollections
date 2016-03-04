//
//  FOCollectionViewDataSource.swift
//  Figure1
//
//  Created by Daniel Krofchick on 2015-04-19.
//  Copyright (c) 2015 Movable Science. All rights reserved.
//

import UIKit

public class FOCollectionViewDataSource: NSObject {

    private(set) var sections = [FOCollectionSection]()
    private var keyCache = [NSIndexPath: String]()
    
    // MARK: Modification
    
    public func insertSections(sections: [FOCollectionSection]?, atIndexes indexes: NSIndexSet, collectionView: UICollectionView, viewController: UIViewController) {
        guard sections != nil else {
            return
        }
        
        indexes.enumerateIndexesUsingBlock { (index, stop) -> Void in
            if let section = sections!.safe(index) {
                section.linkItems(viewController)
                self.sections.insert(section, atIndex: index)
                self.registerClassesForItems(section.items, collectionView: collectionView)
                self.keyCache.removeAll(keepCapacity: true)
            }
        }
    }

    public func deleteSectionsAtIndexes(indexes: NSIndexSet, collectionView: UICollectionView) {
        indexes.enumerateIndexesWithOptions(NSEnumerationOptions.Reverse) { (index, stop) -> Void in
            self.sections.removeAtIndex(index)
            self.keyCache.removeAll(keepCapacity: true)
        }
    }
    
    public func insertItems(items: [FOCollectionItem], atIndexPaths indexPaths: [NSIndexPath], collectionView: UICollectionView, viewController: UIViewController) {
        let (i, p) = privateInsertItems(items, atIndexPaths: indexPaths, collectionView: collectionView, viewController: viewController)
        
        // if items remain throw exception
        assert(i.count == 0, "unable to insert items \(i) at indexPaths \(p)")
        
        keyCache.removeAll(keepCapacity: true)
    }
    
    // Inserts items within current data range. Returns uninserted items.
    private func privateInsertItems(items: [FOCollectionItem], atIndexPaths indexPaths: [NSIndexPath], collectionView: UICollectionView, viewController: UIViewController) -> ([FOCollectionItem], [NSIndexPath]) {
        var unsafeItems = [FOCollectionItem]()
        var unsafeIndexPaths = [NSIndexPath]()

        for (index, indexPath) in indexPaths.enumerate() {
            if let section = sectionAtIndex(indexPath.section) {
                if let item = items.safe(index), count = section.items?.count {
                    if indexPath.row <= count {
                        item.link(section, viewController: viewController)
                        section.items?.insert(item, atIndex: indexPath.row)
                        registerClassesForItems(items, collectionView: collectionView)
                    } else {
                        unsafeItems.append(item)
                        unsafeIndexPaths.append(indexPath)
                    }
                }
            }
        }
        
        return (unsafeItems, unsafeIndexPaths)
    }

    public func deleteItemsAtIndexPaths(var indexPaths: [NSIndexPath], collectionView: UICollectionView) {
        indexPaths.sortInPlace{$0.item > $1.item}
        
        for indexPath in indexPaths {
            if let section = sectionAtIndex(indexPath.section) {
                section.items?.removeAtIndex(indexPath.item)
            }
        }
        
        keyCache.removeAll(keepCapacity: true)
    }
        
    private func registerClassesForSections(sections: [FOCollectionSection]?, collectionView: UICollectionView) {
        guard sections != nil
            else {return}
        
        for section in sections! {
            if let items = section.items {
                self.registerClassesForItems(items, collectionView: collectionView)
            }
        }
    }
    
    private func registerClassesForItems(items: [FOCollectionItem]?, collectionView: UICollectionView) {
        guard items != nil
            else {return}
        
        for item in items! {
            if let cellClass = item.cellClass, reuseIdentifier = item.reuseIdentifier {
                collectionView.registerClass(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
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
    
    public func sectionAtIndex(index: NSInteger) -> FOCollectionSection? {
        return sections.safe(index)
    }
    
    public func itemAtIndexPath(indexPath: NSIndexPath) -> FOCollectionItem? {
        return sectionAtIndex(indexPath.section)?.itemAtIndex(indexPath.row)
    }
    
    public func dataAtIndexPath(indexPath: NSIndexPath) -> AnyObject? {
        return itemAtIndexPath(indexPath)?.data
    }

    public func indexesForSection(section: FOCollectionSection) -> NSIndexSet {
        let indexSet = NSMutableIndexSet()
        
        for (index, s) in sections.enumerate() {
            if section == s {
                indexSet.addIndex(index)
            }
        }
        
        return indexSet
    }
    
    public func indexPathsForItem(item: FOCollectionItem) -> [NSIndexPath] {
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
    
    public func cellsForItem(item: FOCollectionItem, collectionView: UICollectionView) -> [UICollectionViewCell] {
        var cells = [UICollectionViewCell]()
        
        for cell in collectionView.visibleCells() {
            if let indexPath = collectionView.indexPathForCell(cell ) {
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

extension FOCollectionViewDataSource: SequenceType {
    
    public typealias Generator = AnyGenerator<FOCollectionItem>
    
    public func generate() -> Generator {
        var index = Int(0)
        return anyGenerator { () -> FOCollectionItem? in
            return self.itemAtIndex(index++)
        }
    }
    
    func itemAtIndex(index: Int) -> FOCollectionItem? {
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

