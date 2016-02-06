//
//  FOCollectionViewController.swift
//  Figure1
//
//  Created by Daniel Krofchick on 2015-04-19.
//  Copyright (c) 2015 Movable Science. All rights reserved.
//

import UIKit

public class FOCollectionViewController: UICollectionViewController {

    public let dataSource = FOCollectionViewDataSource()
    public var pagingThreshold = CGFloat(1000)
    var cellSizeCache = [String: CGSize]()
    var layoutCellCache = [String: UICollectionViewCell]()
    private var pagingTimer: NSTimer?
    var queue = NSOperationQueue()                              // All table UI updates are performed on this queue to serialize animations
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        queue.qualityOfService = NSQualityOfService.UserInitiated
        queue.name = "CollectionViewController"
        queue.maxConcurrentOperationCount = 1
        
        view.backgroundColor = UIColor.whiteColor()
        
        collectionView?.backgroundColor = UIColor.whiteColor()
        collectionView?.dataSource = dataSource
        collectionView?.delegate = self
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        startPagingTimer()
    }
    
    override public func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        stopPagingTimer()
    }
    
    override public func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
        
        cellSizeCache.removeAll()
        collectionView?.collectionViewLayout.invalidateLayout()
    }
        
    // MARK: Modification

    public func performQueuedWork(work: (() -> ())) {
        queue.addOperation(NSBlockOperation(block: {
            work()
        }))
    }
    
    public func performQueuedBatchUpdates(updates: (() -> ()), completion: ((finished: Bool) -> ())?) {
        queue.addOperation(FOCompletionOperation(work: { (operation) -> Void in
            self.collectionView?.performBatchUpdates({
                updates()
            }, completion: { (finished) -> Void in
                completion?(finished: finished)
                operation.finish()
            })
        }, queue: dispatch_get_main_queue()))
    }
    
    // queued if completion block given
    public func insertSections(sections: [FOCollectionSection], indexes: NSIndexSet, completion: ((finished: Bool) -> ())? = {finished in}) {
        let work = {
            self.dataSource.insertSections(sections, atIndexes: indexes, collectionView: self.collectionView!, viewController: self)
            self.collectionView?.insertSections(indexes)
        }
        
        if completion != nil {
            performQueuedBatchUpdates({work()}, completion: completion)
        } else {
            work()
        }
    }

    // queued if completion block given
    public func deleteSectionsAtIndexes(indexes: NSIndexSet, completion: ((finished: Bool) -> ())? = {finished in}) {
        deleteSections({return indexes}, completion: completion)
    }

    public func deleteSections(indexBlock: (() -> NSIndexSet), completion: ((finished: Bool) -> ())? = {finished in}) {
        let work = {
            let indexes = indexBlock()
            self.dataSource.deleteSectionsAtIndexes(indexes, collectionView: self.collectionView!)
            self.collectionView?.deleteSections(indexes)
        }
        
        if completion != nil {
            performQueuedBatchUpdates({work()}, completion: completion)
        } else {
            work()
        }
    }
    
    // queued if completion block given
    public func insertItems(items: [FOCollectionItem], indexPaths: [NSIndexPath], completion: ((finished: Bool) -> ())? = {finished in}) {
        insertItems({return items}, indexPathsBlock: {return indexPaths}, completion: completion)
    }
    
    public func insertItems(itemsBlock: (() -> [FOCollectionItem]?), indexPathsBlock: (() -> [NSIndexPath]?), completion: ((finished: Bool) -> ())? = {finished in}) {
        let work = {
            if let indexPaths = indexPathsBlock(), items = itemsBlock() {
                self.dataSource.insertItems(items, atIndexPaths: indexPaths, collectionView: self.collectionView!, viewController: self)
                self.collectionView?.insertItemsAtIndexPaths(indexPaths)
            }
        }
        
        if completion != nil {
            performQueuedBatchUpdates({work()}, completion: completion)
        } else {
            work()
        }
    }
    
    public func deleteItemsAtIndexPaths(indexPaths: [NSIndexPath], completion: ((finished: Bool) -> ())? = {finished in}) {
        deleteItems({return indexPaths}, completion: completion)
    }
    
    // queued if completion block given
    public func deleteItems(indexPathsBlock: (() -> [NSIndexPath]?), completion: ((finished: Bool) -> ())? = {finished in}) {
        let work = {
            if let indexPaths = indexPathsBlock() {
                self.dataSource.deleteItemsAtIndexPaths(indexPaths, collectionView: self.collectionView!)
                self.collectionView?.deleteItemsAtIndexPaths(indexPaths)
            }
        }
        
        if completion != nil {
            performQueuedBatchUpdates({work()}, completion: completion)
        } else {
            work()
        }
    }
    
    // queued if completion block given
    public func appendItems(items: [FOCollectionItem], toSectionAtIndex sectionIndex: Int, completion: ((finished: Bool) -> ())? = {finished in}) {
        insertItems({return items}, indexPathsBlock: {
            if let location = self.collectionView?.numberOfItemsInSection(sectionIndex) {
                return NSIndexPath.indexPathsForItemsInRange(NSMakeRange(location, items.count), section: sectionIndex)
            } else {
                return nil
            }
        }, completion: completion)
    }
    
    // queued
    public func clearAllItems(completion: ((finished: Bool) -> ())?) {
        deleteSections({return NSIndexSet(indexesInRange: NSMakeRange(0, self.dataSource.numberOfSectionsInCollectionView(self.collectionView!)))}, completion: completion)
    }
    
    // queued
    public func setPagingState(pagingState: PagingState, sectionIndex: Int, completion: ((finished: Bool) -> ())?) {
        performQueuedBatchUpdates({
            if let section = self.dataSource.sectionAtIndex(sectionIndex) {
                if section.pagingState == pagingState {
                    completion
                } else if pagingState == .Paging && !self.pagingItemExistsForSection(section) {
                    // ADD
                    if let lastIndexPath = self.dataSource.afterLastIndexPathForSectionIndex(0) {
                        self.insertItems([self.pagingItemForSection(section)], indexPaths: [lastIndexPath], completion: nil)
                    }
                } else if (pagingState == .NotPaging || pagingState == .Disabled || pagingState == .Finished) && self.pagingItemExistsForSection(section) {
                    // REMOVE
                    if let lastIndexPath = self.dataSource.lastIndexPathForSectionIndex(0) {
                        self.deleteItemsAtIndexPaths([lastIndexPath], completion: nil)
                    }
                }
                
                section.pagingState = pagingState
            }
        }, completion: completion)
    }
    
    // MARK: Paging
    
    // Implemented by subclass
    public func nextPageForSection(section: Int, collectionView: UICollectionView) {
    }
    
    func startPagingTimer() {
        pagingTimer = NSTimer(timeInterval: 0.2, target: self, selector: Selector("checkForPaging"), userInfo: nil, repeats: true)
        pagingTimer?.tolerance = 0.05
        NSRunLoop.currentRunLoop().addTimer(pagingTimer!, forMode: NSRunLoopCommonModes)
    }

    func stopPagingTimer() {
        pagingTimer?.invalidate()
    }
    
    func checkForPaging() {
        performQueuedBatchUpdates({
            if self.dataSource.sectionsForPagingState(.Paging).count > 0 {
                return
            }
            
            let notPaging = self.dataSource.sectionsForPagingState(.NotPaging)
            
            if notPaging.count > 0 {
                if let indexPath = self.dataSource.lastIndexPathForSectionIndex(notPaging.firstIndex) {
                    if let rect = self.collectionView?.layoutAttributesForItemAtIndexPath(indexPath)?.frame {
                        let distance = CGRectGetMaxY(rect) - (self.collectionView?.contentOffset.y)! - (self.collectionView?.frame.size.height)!
                        
                        if distance < self.pagingThreshold {
                            self.setPagingState(.Paging, sectionIndex: notPaging.firstIndex, completion: { (finished) -> () in
                                self.nextPageForSection(notPaging.firstIndex, collectionView: self.collectionView!)
                            })
                        }
                    }
                }
            }
        }, completion: nil)
    }
        
    public func pagingItemForSection(section: FOCollectionSection) -> FOCollectionItem {
        return FOCollectionPagingItem(section: section)
    }
    
    func pagingItemExistsForSection(section: FOCollectionSection) -> Bool {
        return section.items?.filter({$0.reuseIdentifier == collectionPagingItemReuseIdentifier}).first != nil
    }
    
}

