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
        queue.name = "FOCollectionViewController"
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
    
    public func queueWork(work: (() -> ())) {
        queue.addOperation(NSBlockOperation(block: work))
    }
    
    public func insertSections(sections: [FOCollectionSection]?, indexes: NSIndexSet) {
        if let sections = sections, collectionView = collectionView {
            dataSource.insertSections(sections, atIndexes: indexes, collectionView: collectionView, viewController: self)
            collectionView.insertSections(indexes)
        }
    }

    public func deleteSectionsAtIndexes(indexes: NSIndexSet) {
        if let collectionView = collectionView {
            dataSource.deleteSectionsAtIndexes(indexes, collectionView: collectionView)
            collectionView.deleteSections(indexes)
        }
    }
    
    public func insertItems(items: [FOCollectionItem]?, indexPaths: [NSIndexPath]?) {
        if let items = items, indexPaths = indexPaths, collectionView = collectionView {
            dataSource.insertItems(items, atIndexPaths: indexPaths, collectionView: collectionView, viewController: self)
            collectionView.insertItemsAtIndexPaths(indexPaths)
        }
    }
    
    public func deleteItemsAtIndexPaths(indexPaths: [NSIndexPath]?) {
        if let indexPaths = indexPaths, collectionView = collectionView {
            dataSource.deleteItemsAtIndexPaths(indexPaths, collectionView: collectionView)
            collectionView.deleteItemsAtIndexPaths(indexPaths)
        }
    }

    public func appendItems(items: [FOCollectionItem], toSectionAtIndex sectionIndex: Int) {
        if let collectionView = collectionView {
            if let section = dataSource.sectionAtIndex(sectionIndex) {
                var location = collectionView.numberOfItemsInSection(sectionIndex)
                
                if dataSource.pagingIndexPath(section) != nil {
                    location--
                }
                
                let indexPaths = NSIndexPath.indexPathsForItemsInRange(NSMakeRange(location, items.count), section: sectionIndex)
                insertItems(items, indexPaths: indexPaths)
            }
        }
    }
    
    public func clearAllItems() {
        if let collectionView = collectionView {
            let indexes = NSIndexSet(indexesInRange: NSMakeRange(0, dataSource.numberOfSectionsInCollectionView(collectionView)))
            deleteSectionsAtIndexes(indexes)
        }
    }
    
    public func setPagingState(pagingState: PagingState, sectionIndex: Int) {
        if let section = dataSource.sectionAtIndex(sectionIndex) {
            let pagingIndexPath = dataSource.pagingIndexPath(section)

            if section.pagingState == pagingState {
            } else if pagingState == .Paging && pagingIndexPath == nil {
                // ADD
                if var pagingIndexPath = dataSource.lastIndexPathForSectionIndex(sectionIndex) {
                    pagingIndexPath = NSIndexPath(forRow: pagingIndexPath.row + 1, inSection: pagingIndexPath.section)
                    let pagingItem = dataSource.pagingItemForSection(section)
                    insertItems([pagingItem], indexPaths: [pagingIndexPath])
                }
            } else if (pagingState == .NotPaging || pagingState == .Disabled || pagingState == .Finished) {
                // REMOVE
                if let pagingIndexPath = pagingIndexPath {
                    deleteItemsAtIndexPaths([pagingIndexPath])
                }
            }
            
            section.pagingState = pagingState
        }
    }
    
    public func refreshVisibleCells() {
        if let collectionView = collectionView {
            for indexPath in collectionView.indexPathsForVisibleItems() {
                if let cell = collectionView.cellForItemAtIndexPath(indexPath), item = dataSource.itemAtIndexPath(indexPath) {
                    item.configure(cell, collectionView: collectionView, indexPath: indexPath)
                }
            }
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
        if dataSource.sectionsForPagingState(.Paging).count > 0 {
            return
        }
        
        let notPaging = dataSource.sectionsForPagingState(.NotPaging)

        if notPaging.count > 0 {
            if let indexPath = dataSource.lastIndexPathForSectionIndex(notPaging.firstIndex), collectionView = collectionView {
                if let rect = collectionView.layoutAttributesForItemAtIndexPath(indexPath)?.frame {
                    let distance = CGRectGetMaxY(rect) - (collectionView.contentOffset.y) - (collectionView.frame.size.height)
                    
                    if distance < pagingThreshold {
                        queueUpdate({
                            [weak self] in
                            self?.setPagingState(.Paging, sectionIndex: notPaging.firstIndex)
                        }, completion: {
                            [weak self] finished in
                            if let collectionView = self?.collectionView {
                                self?.nextPageForSection(notPaging.firstIndex, collectionView: collectionView)
                            }
                        })
                    }
                }
            }
        }
    }
    
}
