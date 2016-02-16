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

    public func queueUpdate(update: (() -> ()), completion: ((finished: Bool) -> ())? = nil) {
        queue.addOperation(FOCompletionOperation(work: {[weak self] (operation) -> Void in
            self?.collectionView?.performBatchUpdates({
                update()
            }, completion: { (finished) -> Void in
                completion?(finished: finished)
                operation.finish()
            })
        }, queue: dispatch_get_main_queue()))
    }
    
    // queued if completion block given
    public func insertSections(sections: [FOCollectionSection]?, indexes: NSIndexSet, completion: ((finished: Bool) -> ())? = {finished in}) {
        let work = {
            [weak self] in
            if let sections = sections, collectionView = self?.collectionView {
                self?.dataSource.insertSections(sections, atIndexes: indexes, collectionView: collectionView, viewController: self)
                collectionView.insertSections(indexes)
            }
        }
        
        process(work: work, completion: completion)
    }

    // queued if completion block given
    public func deleteSectionsAtIndexes(indexes: NSIndexSet, completion: ((finished: Bool) -> ())? = {finished in}) {
        let work = {
            [weak self] in
            if let collectionView = self?.collectionView {
                self?.dataSource.deleteSectionsAtIndexes(indexes, collectionView: collectionView)
                collectionView.deleteSections(indexes)
            }
        }
        
        process(work: work, completion: completion)
    }
    
    // queued if completion block given
    public func insertItems(items: [FOCollectionItem]?, indexPaths: [NSIndexPath]?, completion: ((finished: Bool) -> ())? = {finished in}) {
        let work = {
            [weak self] in
            if let items = items, indexPaths = indexPaths, collectionView = self?.collectionView {
                self?.dataSource.insertItems(items, atIndexPaths: indexPaths, collectionView: collectionView, viewController: self)
                collectionView.insertItemsAtIndexPaths(indexPaths)
            }
        }
        
        process(work: work, completion: completion)
    }
    
    // queued if completion block given
    public func deleteItemsAtIndexPaths(indexPaths: [NSIndexPath]?, completion: ((finished: Bool) -> ())? = {finished in}) {
        let work = {
            [weak self] in
            if let indexPaths = indexPaths, collectionView = self?.collectionView {
                self?.dataSource.deleteItemsAtIndexPaths(indexPaths, collectionView: collectionView)
                collectionView.deleteItemsAtIndexPaths(indexPaths)
            }
        }
        
        process(work: work, completion: completion)
    }
    
    // queued if completion block given
    public func appendItems(items: [FOCollectionItem], toSectionAtIndex sectionIndex: Int, completion: ((finished: Bool) -> ())? = {finished in}) {
        let work = {
            [weak self] in
            if let location = self?.collectionView?.numberOfItemsInSection(sectionIndex) {
                let indexPaths = NSIndexPath.indexPathsForItemsInRange(NSMakeRange(location, items.count), section: sectionIndex)
                self?.insertItems(items, indexPaths: indexPaths)
            }
        }
        
        process(work: work, completion: completion)
    }
    
    // queued
    public func clearAllItems(completion: ((finished: Bool) -> ())? = {finished in}) {
        let work = {
            [weak self] in
            if let collectionView = self?.collectionView, dataSource = self?.dataSource {
                let indexes = NSIndexSet(indexesInRange: NSMakeRange(0, dataSource.numberOfSectionsInCollectionView(collectionView)))
                self?.deleteSectionsAtIndexes(indexes)
            }
        }
        
        process(work: work, completion: completion)
    }
    
    // queued
    public func setPagingState(pagingState: PagingState, sectionIndex: Int, completion: ((finished: Bool) -> ())? = {finished in}) {
        let work = {
            [weak self] in
            if let dataSource = self?.dataSource {
                if let section = dataSource.sectionAtIndex(sectionIndex) {
                    if let pagingItemExists = self?.pagingItemExistsForSection(section) {
                        if section.pagingState == pagingState {
                            completion
                        } else if pagingState == .Paging && !pagingItemExists {
                            // ADD
                            if let pagingItem = self?.pagingItemForSection(section) {
                                if let lastIndexPath = dataSource.afterLastIndexPathForSectionIndex(0) {
                                    self?.insertItems([pagingItem], indexPaths: [lastIndexPath], completion: nil)
                                }
                            }
                        } else if (pagingState == .NotPaging || pagingState == .Disabled || pagingState == .Finished) && pagingItemExists {
                            // REMOVE
                            if let lastIndexPath = dataSource.lastIndexPathForSectionIndex(0) {
                                self?.deleteItemsAtIndexPaths([lastIndexPath], completion: nil)
                            }
                        }
                        
                        section.pagingState = pagingState
                    }
                }
            }
        }
        
        process(work: work, completion: completion)
    }
    
    private func process(work work: (()->()), completion: ((finished: Bool)->())?) {
        if completion == nil {
            work()
        } else {
            queueUpdate({work()}, completion: completion)
        }
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
        queueUpdate({
            [weak self] in
            
            if self?.dataSource.sectionsForPagingState(.Paging).count > 0 {
                return
            }
            
            if let notPaging = self?.dataSource.sectionsForPagingState(.NotPaging), collectionView = self?.collectionView {
                if notPaging.count > 0 {
                    if let indexPath = self?.dataSource.lastIndexPathForSectionIndex(notPaging.firstIndex) {
                        if let rect = collectionView.layoutAttributesForItemAtIndexPath(indexPath)?.frame {
                            let distance = CGRectGetMaxY(rect) - (collectionView.contentOffset.y) - (collectionView.frame.size.height)
                            
                            if distance < self?.pagingThreshold {
                                self?.setPagingState(.Paging, sectionIndex: notPaging.firstIndex, completion: { (finished) -> () in
                                    self?.nextPageForSection(notPaging.firstIndex, collectionView: collectionView)
                                })
                            }
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

