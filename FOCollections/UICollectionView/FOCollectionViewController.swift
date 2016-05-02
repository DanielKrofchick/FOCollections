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
    public var queue = NSOperationQueue()                              // All table UI updates are performed on this queue to serialize animations
    
    public override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        
        privateInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        privateInit()
    }
    
    func privateInit() {
        queue.qualityOfService = NSQualityOfService.UserInitiated
        queue.name = "FOCollectionViewController"
        queue.maxConcurrentOperationCount = 1
        queue.suspended = true
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        collectionView?.backgroundColor = UIColor.whiteColor()
        collectionView?.dataSource = dataSource
        collectionView?.delegate = self
        
        queue.suspended = false
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
        
        cellSizeCache.removeAll(keepCapacity: true)
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
            if let indexPaths = dataSource.appendItems(items, toSectionAtIndex: sectionIndex, collectionView: collectionView, viewController: self) {
                collectionView.insertItemsAtIndexPaths(indexPaths)
            }
        }
    }
    
    public func prependItems(items: [FOCollectionItem], toSectionAtIndex sectionIndex: Int) {
        if let section = dataSource.sectionAtIndex(sectionIndex) {
            var location = 0
            
            if section.pagingDirection == .Up && pagingIndexPath(section) != nil {
                location += 1
            }
            
            let indexPaths = NSIndexPath.indexPathsForItemsInRange(NSMakeRange(location, items.count), section: sectionIndex)
            insertItems(items, indexPaths: indexPaths)
        }
    }
    
    public func clearAllItems() {
        if let collectionView = collectionView {
            let indexes = NSIndexSet(indexesInRange: NSMakeRange(0, dataSource.numberOfSectionsInCollectionView(collectionView)))
            deleteSectionsAtIndexes(indexes)
        }
    }
    
    public func setPagingState(pagingState: PagingState, sectionIndex: Int) {
        if let collectionView = collectionView {
            if let indexPath = dataSource.setPagingState(pagingState, sectionIndex: sectionIndex, collectionView: collectionView, viewController: self) {
                if pagingState == .Paging {
                    collectionView.insertItemsAtIndexPaths([indexPath])
                } else {
                    collectionView.deleteItemsAtIndexPaths([indexPath])
                }
            }
        }
    }
    
    func pagingIndexPath(section: FOCollectionSection) -> NSIndexPath? {
        let item = pagingItemForSection(section)
        
        return dataSource.indexPathsForItem(item).first
    }
    
    public func pagingItemForSection(section: FOCollectionSection) -> FOCollectionItem {
        return FOCollectionPagingItem(section: section)
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
    public func nextPageForSection(section: FOCollectionSection, collectionView: UICollectionView) {
    }
    
    func startPagingTimer() {
        pagingTimer = NSTimer(timeInterval: 0.2, target: self, selector: #selector(FOCollectionViewController.checkForPaging), userInfo: nil, repeats: true)
        pagingTimer?.tolerance = 0.05
        NSRunLoop.currentRunLoop().addTimer(pagingTimer!, forMode: NSRunLoopCommonModes)
    }

    func stopPagingTimer() {
        pagingTimer?.invalidate()
    }
    
    func checkForPaging() {
        addPagingCellIfNeeded()
        triggerPagingIfNeeded()
    }
    
    func addPagingCellIfNeeded() {
        if dataSource.sectionsForPagingState(.Paging).count > 0 {
            return
        }
        
        let notPaging = dataSource.sectionsForPagingState(.NotPaging)
        
        if notPaging.count > 0 {
            if let section = dataSource.sectionAtIndex(notPaging.firstIndex) {
                if pagingIndexPath(section) == nil {
                    queueUpdate({
                        [weak self] in
                        self?.setPagingState(.Paging, sectionIndex: notPaging.firstIndex)
                    })
                }
            }
        }
    }
    
    func triggerPagingIfNeeded() {
        if dataSource.sectionsForPagingState(.PagingAndFetching).firstIndex != NSNotFound {
            return
        }
        
        let sectionIndex = dataSource.sectionsForPagingState(.Paging).firstIndex
        
        if sectionIndex == NSNotFound {
            return
        }
        
        if let section = dataSource.sectionAtIndex(sectionIndex) {
            if let indexPath = pagingIndexPath(section), collectionView = collectionView {
                if let rect = collectionView.layoutAttributesForItemAtIndexPath(indexPath)?.frame {
                    var distance = CGFloat.max
                    
                    if section.pagingDirection == .Down {
                        distance = CGRectGetMinY(rect) - collectionView.contentOffset.y - collectionView.frame.size.height
                    } else if section.pagingDirection == .Up {
                        distance = collectionView.contentOffset.y - CGRectGetMaxY(rect)
                    }
                    
                    if distance < pagingThreshold {
                        section.pagingState = .PagingAndFetching
                        nextPageForSection(section, collectionView: collectionView)
                    }
                }
            }
        }
    }
    
    public func clearCellSizeCache(keepCapacity: Bool = true) {
        cellSizeCache.removeAll(keepCapacity: keepCapacity)
    }
    
}
