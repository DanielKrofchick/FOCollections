//
//  FOCollectionViewDataSource.swift
//  Figure1
//
//  Created by Daniel Krofchick on 2015-04-19.
//  Copyright (c) 2015 Movable Science. All rights reserved.
//

import UIKit

open class FOCollectionViewDataSource: NSObject {

    open fileprivate(set) var sections = [FOCollectionSection]()
    fileprivate var keyCache = [IndexPath: String]()
    
    // MARK: Modification
    
    open func insertSections(_ sections: [FOCollectionSection]?, atIndexes indexes: IndexSet, collectionView: UICollectionView, viewController: UIViewController) {
        guard sections != nil else {
            return
        }
        
        indexes.enumerated().forEach {
            i, index in
            if let section = sections?.safe(i) {
                section.linkItems(viewController)
                self.sections.insert(section, at: index)
                self.registerClassesForItems(section.items, collectionView: collectionView)
                self.keyCache.removeAll(keepingCapacity: true)
            }
        }
    }
    
    open func appendSection(_ section: FOCollectionSection, collectionView: UICollectionView, viewController: UIViewController) {
        section.linkItems(viewController)
        self.sections.append(section)
        self.registerClassesForItems(section.items, collectionView: collectionView)
        self.keyCache.removeAll(keepingCapacity: true)
    }

    open func deleteSectionsAtIndexes(_ indexes: IndexSet, collectionView: UICollectionView) {
        (indexes as NSIndexSet).enumerate(options: NSEnumerationOptions.reverse) { (index, stop) -> Void in
            self.sections.remove(at: index)
            self.keyCache.removeAll(keepingCapacity: true)
        }
    }
    
    open func insertItems(_ items: [FOCollectionItem], atIndexPaths indexPaths: [IndexPath], collectionView: UICollectionView, viewController: UIViewController) {
        let (i, p) = privateInsertItems(items, atIndexPaths: indexPaths, collectionView: collectionView, viewController: viewController)
        
        // if items remain throw exception
        assert(i.count == 0, "unable to insert items \(i) at indexPaths \(p)")
        
        keyCache.removeAll(keepingCapacity: true)
    }
    
    // Inserts items within current data range. Returns uninserted items.
    fileprivate func privateInsertItems(_ items: [FOCollectionItem], atIndexPaths indexPaths: [IndexPath], collectionView: UICollectionView, viewController: UIViewController) -> ([FOCollectionItem], [IndexPath]) {
        var unsafeItems = [FOCollectionItem]()
        var unsafeIndexPaths = [IndexPath]()

        for (index, indexPath) in indexPaths.enumerated() {
            if let section = sectionAtIndex(indexPath.section) {
                if let item = items.safe(index), let count = section.items?.count {
                    if indexPath.row <= count {
                        item.link(section, viewController: viewController)
                        section.items?.insert(item, at: indexPath.row)
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

    open func deleteItemsAtIndexPaths(_ indexPaths: [IndexPath], collectionView: UICollectionView) {
        for indexPath in indexPaths.sorted(by: {$0.item > $1.item}) {
            if let section = sectionAtIndex(indexPath.section) {
                section.items?.remove(at: indexPath.item)
            }
        }
        
        keyCache.removeAll(keepingCapacity: true)
    }
    
    @discardableResult
    open func appendItems(_ items: [FOCollectionItem], toSectionAtIndex sectionIndex: Int, collectionView: UICollectionView, viewController: UIViewController) -> [IndexPath]? {
        var indexPaths: [IndexPath]? = nil

        if let section = sectionAtIndex(sectionIndex), var location = section.items?.count  {
            if let viewController = viewController as? FOCollectionViewController {
                if section.pagingDirection == .down && viewController.pagingIndexPath(section) != nil {
                    location -= 1
                }
            }
            
            indexPaths = IndexPath.indexPathsForItemsInRange(NSMakeRange(location, items.count), section: sectionIndex)
            
            if let indexPaths = indexPaths {
                insertItems(items, atIndexPaths: indexPaths, collectionView: collectionView, viewController: viewController)
            }
        }
        
        return indexPaths
    }
    
    @discardableResult
    open func prependItems(_ items: [FOCollectionItem], toSectionAtIndex sectionIndex: Int, collectionView: UICollectionView, viewController: UIViewController) -> [IndexPath]? {
        var indexPaths: [IndexPath]? = nil
        
        if let section = sectionAtIndex(sectionIndex) {
            var location = 0
            
            if let viewController = viewController as? FOCollectionViewController {
                if section.pagingDirection == .up && viewController.pagingIndexPath(section) != nil {
                    location += 1
                }
            }
            
            indexPaths = IndexPath.indexPathsForItemsInRange(NSMakeRange(location, items.count), section: sectionIndex)
            
            if let indexPaths = indexPaths {
                insertItems(items, atIndexPaths: indexPaths, collectionView: collectionView, viewController: viewController)
            }
        }
        
        return indexPaths
    }
    
    @discardableResult
    open func clearAllItems(_ collectionView: UICollectionView) -> IndexSet? {
        let indexes = IndexSet(integersIn: NSMakeRange(0, numberOfSections(in: collectionView)).toRange()!)
        deleteSectionsAtIndexes(indexes, collectionView: collectionView)
        
        return indexes.count == 0 ? nil : indexes
    }
    
    @discardableResult
    open func setPagingState(_ pagingState: PagingState, sectionIndex: Int, collectionView: UICollectionView, viewController: UIViewController) -> IndexPath? {
        var pagingIndexPath: IndexPath? = nil
        
        if let section = sectionAtIndex(sectionIndex), let viewController = viewController as? FOCollectionViewController {
            pagingIndexPath = viewController.pagingIndexPath(section)
            
            if section.pagingState == pagingState {
                pagingIndexPath = nil
            } else if pagingState == .paging && pagingIndexPath == nil {
                // ADD
                if section.pagingDirection == .down {
                    if let p = lastIndexPathForSectionIndex(sectionIndex) {
                        pagingIndexPath = IndexPath(row: p.row + 1, section: p.section)
                    }
                } else if section.pagingDirection == .up {
                    pagingIndexPath = IndexPath(item: 0, section: 0)
                }
                
                if let pagingIndexPath = pagingIndexPath {
                    let pagingItem = viewController.pagingItemForSection(section)
                    insertItems([pagingItem], atIndexPaths: [pagingIndexPath], collectionView: collectionView, viewController: viewController)
                }
            } else if (pagingState == .notPaging || pagingState == .disabled || pagingState == .finished) {
                // REMOVE
                if let pagingIndexPath = pagingIndexPath {
                    deleteItemsAtIndexPaths([pagingIndexPath], collectionView: collectionView)
                }
            } else {
                pagingIndexPath = nil
            }
            
            section.pagingState = pagingState
        }
        
        return pagingIndexPath
    }
    
    fileprivate func registerClassesForSections(_ sections: [FOCollectionSection]?, collectionView: UICollectionView) {
        guard sections != nil
            else {return}
        
        for section in sections! {
            if let items = section.items {
                self.registerClassesForItems(items, collectionView: collectionView)
            }
        }
    }
    
    fileprivate func registerClassesForItems(_ items: [FOCollectionItem]?, collectionView: UICollectionView) {
        guard items != nil
            else {return}
        
        for item in items! {
            if let cellClass = item.cellClass, let reuseIdentifier = item.reuseIdentifier {
                collectionView.register(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
            }
        }
    }
    
    // MARK: - PAGING
    
    func sectionsForPagingState(_ pagingState: PagingState) -> IndexSet {
        let result = NSMutableIndexSet()
        
        for (index, section) in sections.enumerated() {
            if section.pagingState == pagingState {
                result.add(index)
            }
        }
        
        return result as IndexSet
    }
    
    func lastIndexPathForSectionIndex(_ section: Int) -> IndexPath? {
        if let items = sectionAtIndex(section)?.items {
            return IndexPath(item: items.count - 1, section: section)
        } else {
            return nil
        }
    }
    
    // MARK: - Lookup
    func keyForItemAtIndexPath(_ indexPath: IndexPath) -> String? {
        if let key = keyCache[indexPath] {
            return key
        } else if let item = itemAtIndexPath(indexPath) {
            let key = "\(String(describing: item.identifier))-\(indexPath.section)-\(indexPath.row)"
            keyCache[indexPath] = key
            return key
        } else {
            return nil
        }
    }
    
    open func sectionAtIndex(_ index: NSInteger) -> FOCollectionSection? {
        return sections.safe(index)
    }
    
    open func itemAtIndexPath(_ indexPath: IndexPath) -> FOCollectionItem? {
        return sectionAtIndex(indexPath.section)?.itemAtIndex(indexPath.row)
    }
    
    open func dataAtIndexPath(_ indexPath: IndexPath) -> AnyObject? {
        return itemAtIndexPath(indexPath)?.data
    }

    open func indexesForSection(section: FOCollectionSection) -> IndexSet {
        let indexSet = NSMutableIndexSet()
        
        for (index, s) in sections.enumerated() {
            if section == s {
                indexSet.add(index)
            }
        }
        
        return indexSet as IndexSet
    }
    
    open func indexesForSection(identifier: String) -> IndexSet {
        let indexSet = NSMutableIndexSet()
        
        for (index, s) in sections.enumerated() {
            if identifier == s.identifier {
                indexSet.add(index)
            }
        }
        
        return indexSet as IndexSet
    }
    
    open func indexPathsForItem(_ item: FOCollectionItem) -> [IndexPath] {
        var indexPaths = [IndexPath]()
        
        for (sectionIndex, section) in sections.enumerated() {
            indexPaths.append(contentsOf: section.indexPathsForItem(item, section: sectionIndex))
        }
        
        return indexPaths
    }
    
    open func indexPathsForData(_ data: AnyObject) -> [IndexPath]? {
        var indexPaths = [IndexPath]()
        
        for (sectionIndex, section) in sections.enumerated() {
            indexPaths.append(contentsOf: section.indexPathsForData(data, section: sectionIndex))
        }
        
        return indexPaths
    }
    
    open func indexPathsFor(sectionAtIndex index: Int) -> [IndexPath] {
        var indexPaths = [IndexPath]()
        
        let items = sectionAtIndex(index)?.items?.count ?? 0
        
        for itemIndex in 0..<items {
            indexPaths.append(IndexPath(item: itemIndex, section: index))
        }
        
        return indexPaths
    }
    
    open func cellsForItem(_ item: FOCollectionItem, collectionView: UICollectionView) -> [UICollectionViewCell] {
        var cells = [UICollectionViewCell]()
        
        for cell in collectionView.visibleCells {
            if let indexPath = collectionView.indexPath(for: cell ) {
                if let foundItem = itemAtIndexPath(indexPath) {
                    if item == foundItem {
                        cells.append(cell)
                    }
                }
            }
        }
        
        return cells
    }
    
    open func count() -> Int {
        var count = Int(0)
        
        for section in sections {
            if let items = section.items {
                count += items.count
            }
        }
        
        return count
    }
    
    open func equalData(_ sections: [FOCollectionSection]) -> Bool {
        var equal = true
        
        let new = FOCollectionViewDataSource()
        new.sections = sections
        
        if count() == new.count() {
            for i in 0..<new.count() {
                if new.itemAtIndex(i) != itemAtIndex(i) {
                    equal = false
                    break
                }
            }
        } else {
            equal = false
        }
        
        return equal
    }
    
}

extension FOCollectionViewDataSource: Sequence {
    
    public typealias Iterator = AnyIterator<FOCollectionItem>
    
    public func makeIterator() -> Iterator {
        var index = Int(0)
        return AnyIterator { () -> FOCollectionItem? in
            let item = self.itemAtIndex(index)
            index += 1
            return item
        }
    }
    
    func itemAtIndex(_ index: Int) -> FOCollectionItem? {
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
    
    public func indexPathForIndex(_ index: Int) -> IndexPath? {
        var i = 0
        
        for (s, section) in sections.enumerated() {
            if i <= index {
                if let items = section.items {
                    if let _ = items.safe(index - i) {
                        return IndexPath(row: index - i, section: s)
                    } else {
                        i += items.count
                    }
                }
            }
        }
        
        return nil
    }
    
    public func indexForIndexPath(_ indexPath: IndexPath) -> Int? {
        var i = 0
        
        for (index, section) in sections.enumerated() {
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
    
    public func previousIndexPath(_ indexPath: IndexPath) -> IndexPath? {
        if let index = indexForIndexPath(indexPath) {
            return indexPathForIndex(index - 1)
        }
        
        return nil
    }
    
    public func nextIndexPath(_ indexPath: IndexPath) -> IndexPath? {
        if let index = indexForIndexPath(indexPath) {
            return indexPathForIndex(index + 1)
        }
        
        return nil
    }
    
}

