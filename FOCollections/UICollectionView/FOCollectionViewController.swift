//
//  FOCollectionViewController.swift
//  Figure1
//
//  Created by Daniel Krofchick on 2015-04-19.
//  Copyright (c) 2015 Movable Science. All rights reserved.
//

import UIKit

open class FOCollectionViewController: UICollectionViewController {

    open let dataSource = FOCollectionViewDataSource()
    open var pagingThreshold = CGFloat(1000)
    var cellSizeCache = [String: CGSize]()
    var layoutCellCache = [String: UICollectionViewCell]()
    fileprivate var pagingTimer: Timer?
    open var queue = OperationQueue()                              // All table UI updates are performed on this queue to serialize animations
    
    public override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        
        privateInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        privateInit()
    }
    
    func privateInit() {
        queue.qualityOfService = QualityOfService.userInitiated
        queue.name = "FOCollectionViewController"
        queue.maxConcurrentOperationCount = 1
        queue.isSuspended = true
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 10.0, *) {
            collectionView?.isPrefetchingEnabled = false
        }
        
        view.backgroundColor = UIColor.white
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.dataSource = dataSource
        collectionView?.delegate = self
        
        queue.isSuspended = false
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startPagingTimer()
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        stopPagingTimer()
    }
    
    override open func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        cellSizeCache.removeAll(keepingCapacity: true)
        collectionView?.collectionViewLayout.invalidateLayout()
    }
        
    // MARK: Modification

    open func queueUpdate(_ update: @escaping (() -> ()), completion: ((_ finished: Bool) -> ())? = nil) {
        queue.addOperation(FOCompletionOperation(work: {[weak self] (operation) -> Void in
            self?.collectionView?.performBatchUpdates({
                update()
            }, completion: { (finished) -> Void in
                completion?(finished)
                operation.finish()
            })
        }, queue: DispatchQueue.main))
    }
    
    open func queueWork(_ work: @escaping (() -> ())) {
        queue.addOperation(BlockOperation(block: work))
    }
        
    open func insertSections(_ sections: [FOCollectionSection]?, indexes: IndexSet) {
        if let sections = sections, let collectionView = collectionView {
            dataSource.insertSections(sections, atIndexes: indexes, collectionView: collectionView, viewController: self)
            collectionView.insertSections(indexes)
        }
    }

    open func deleteSectionsAtIndexes(_ indexes: IndexSet) {
        if let collectionView = collectionView {
            dataSource.deleteSectionsAtIndexes(indexes, collectionView: collectionView)
            collectionView.deleteSections(indexes)
        }
    }
    
    open func insertItems(_ items: [FOCollectionItem]?, indexPaths: [IndexPath]?) {
        if let items = items, let indexPaths = indexPaths, let collectionView = collectionView {
            dataSource.insertItems(items, atIndexPaths: indexPaths, collectionView: collectionView, viewController: self)
            collectionView.insertItems(at: indexPaths)
        }
    }
    
    open func deleteItemsAtIndexPaths(_ indexPaths: [IndexPath]?) {
        if let indexPaths = indexPaths, let collectionView = collectionView {
            dataSource.deleteItemsAtIndexPaths(indexPaths, collectionView: collectionView)
            collectionView.deleteItems(at: indexPaths)
        }
    }

    open func appendItems(_ items: [FOCollectionItem], toSectionAtIndex sectionIndex: Int) {
        if let collectionView = collectionView {
            if let indexPaths = dataSource.appendItems(items, toSectionAtIndex: sectionIndex, collectionView: collectionView, viewController: self) {
                collectionView.insertItems(at: indexPaths)
            }
        }
    }
    
    open func prependItems(_ items: [FOCollectionItem], toSectionAtIndex sectionIndex: Int) {
        if let section = dataSource.sectionAtIndex(sectionIndex) {
            var location = 0
            
            if section.pagingDirection == .up && pagingIndexPath(section) != nil {
                location += 1
            }
            
            let indexPaths = IndexPath.indexPathsForItemsInRange(NSMakeRange(location, items.count), section: sectionIndex)
            insertItems(items, indexPaths: indexPaths)
        }
    }
    
    open func clearAllItems() {
        if let collectionView = collectionView {
            let indexes = IndexSet(integersIn: NSMakeRange(0, dataSource.numberOfSections(in: collectionView)).toRange()!)
            deleteSectionsAtIndexes(indexes)
        }
    }
    
    open func setPagingState(_ pagingState: PagingState, sectionIndex: Int) {
        if let collectionView = collectionView {
            if let indexPath = dataSource.setPagingState(pagingState, sectionIndex: sectionIndex, collectionView: collectionView, viewController: self) {
                if pagingState == .paging {
                    collectionView.insertItems(at: [indexPath])
                } else {
                    collectionView.deleteItems(at: [indexPath])
                }
            }
        }
    }
    
    func pagingIndexPath(_ section: FOCollectionSection) -> IndexPath? {
        let item = pagingItemForSection(section)
        
        return dataSource.indexPathsForItem(item).first
    }
    
    open func pagingItemForSection(_ section: FOCollectionSection) -> FOCollectionItem {
        return FOCollectionPagingItem(section: section)
    }
    
    open func refreshVisibleCells() {
        if let collectionView = collectionView {
            for indexPath in collectionView.indexPathsForVisibleItems {
                if let cell = collectionView.cellForItem(at: indexPath), let item = dataSource.itemAtIndexPath(indexPath) {
                    item.configure(cell, collectionView: collectionView, indexPath: indexPath)
                }
            }
        }
    }
    
    // MARK: Paging
    
    // Implemented by subclass
    open func nextPageForSection(_ section: FOCollectionSection, collectionView: UICollectionView) {
    }
    
    func startPagingTimer() {
        pagingTimer = Timer(timeInterval: 0.2, target: self, selector: #selector(FOCollectionViewController.checkForPaging), userInfo: nil, repeats: true)
        pagingTimer?.tolerance = 0.05
        RunLoop.current.add(pagingTimer!, forMode: RunLoopMode.commonModes)
    }

    func stopPagingTimer() {
        pagingTimer?.invalidate()
    }
    
    func checkForPaging() {
        addPagingCellIfNeeded()
        triggerPagingIfNeeded()
    }
    
    func addPagingCellIfNeeded() {
        if dataSource.sectionsForPagingState(.paging).count > 0 {
            return
        }
        
        let notPaging = dataSource.sectionsForPagingState(.notPaging)
        
        if let data = notPaging.first {
            if let section = dataSource.sectionAtIndex(data) {
                if pagingIndexPath(section) == nil {
                    queueUpdate({
                        [weak self] in
                        self?.setPagingState(.paging, sectionIndex: data)
                    })
                }
            }
        }
    }
    
    func triggerPagingIfNeeded() {
        if dataSource.sectionsForPagingState(.pagingAndFetching).first != nil {
            return
        }
        
        guard let sectionIndex = dataSource.sectionsForPagingState(.paging).first else {
            return
        }
        
        if let section = dataSource.sectionAtIndex(sectionIndex) {
            if let indexPath = pagingIndexPath(section), let collectionView = collectionView {
                if let rect = collectionView.layoutAttributesForItem(at: indexPath)?.frame {
                    var distance = CGFloat.greatestFiniteMagnitude
                    
                    if section.pagingDirection == .down {
                        distance = rect.minY - collectionView.contentOffset.y - collectionView.frame.size.height
                    } else if section.pagingDirection == .up {
                        distance = collectionView.contentOffset.y - rect.maxY
                    }
                    
                    if distance < pagingThreshold {
                        section.pagingState = .pagingAndFetching
                        nextPageForSection(section, collectionView: collectionView)
                    }
                }
            }
        }
    }
    
    open func clearCellSizeCache(indexPaths: [IndexPath]? = nil, keepCapacity: Bool = true) {
        if let indexPaths = indexPaths {
            indexPaths.forEach {
                (indexPath) in
                if let key = dataSource.keyForItemAtIndexPath(indexPath) {
                    cellSizeCache[key] = nil
                }
            }
        } else {
            cellSizeCache.removeAll(keepingCapacity: keepCapacity)
        }
    }
    
}
