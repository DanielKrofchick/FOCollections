//
//  FOTableViewController.swift
//  Figure1
//
//  Created by Daniel Krofchick on 2015-04-23.
//  Copyright (c) 2015 Movable Science. All rights reserved.
//

import UIKit

public class FOTableViewController: UIViewController, UITableViewDelegate {

    public var tableView = UITableView()
    public let dataSource = FOTableViewDataSource()
    public var pagingThreshold = CGFloat(1000)
    var cellSizeCache = [String: CGFloat]()
    var layoutCellCache = [String: UITableViewCell]()
    private var pagingTimer: NSTimer?
    var queue = NSOperationQueue()                              // All table UI updates are performed on this queue to serialize animations
    public var updateDuration = NSTimeInterval(0.5)
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        queue.qualityOfService = NSQualityOfService.UserInitiated
        queue.name = "FOTableViewController"
        queue.maxConcurrentOperationCount = 1
        
        view.backgroundColor = UIColor.whiteColor()
        
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.dataSource = dataSource
        tableView.delegate = self
        view.addSubview(tableView)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
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
        tableView.reloadData()
    }
        
    // MARK: Modification
    
    func tableUpdate(update: (() -> ()), duration: NSTimeInterval, completion: (() -> ())?) {
        UIView.beginAnimations("FOTableViewController", context: nil)
        UIView.setAnimationDuration(duration)
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion?()
        }
        tableView.beginUpdates()
        update()
        tableView.endUpdates()
        CATransaction.commit()
        UIView.commitAnimations()
    }

    public func queueUpdate(update: (() -> ()), completion: (() -> ())? = nil) {
        queue.addOperation(FOCompletionOperation(work: {[weak self] (operation) -> Void in
            if self == nil {
                operation.finish()
                return
            }
            
            self!.tableUpdate(update, duration: self!.updateDuration, completion: { () -> () in
                completion?()
                operation.finish()
            })
        }, queue: dispatch_get_main_queue()))
    }
    
    public func queueWork(work: (() -> ())) {
        queue.addOperation(NSBlockOperation(block: work))
    }
    
    public func insertSections(sections: [FOTableSection], indexes: NSIndexSet) {
        dataSource.insertSections(sections, atIndexes: indexes, tableView: tableView, viewController: self)
        tableView.insertSections(indexes, withRowAnimation: .Fade)
    }
    
    public func deleteSectionsAtIndexes(indexes: NSIndexSet) {
        dataSource.deleteSectionsAtIndexes(indexes, tableView: tableView)
        tableView.deleteSections(indexes, withRowAnimation: .Fade)
    }
    
    public func insertItems(items: [FOTableItem], indexPaths: [NSIndexPath]) {
        dataSource.insertItems(items, atIndexPaths: indexPaths, tableView: tableView, viewController: self)
        tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
    }
    
    public func deleteItemsAtIndexPaths(indexPaths: [NSIndexPath]) {
        dataSource.deleteItemsAtIndexPaths(indexPaths, tableView: tableView)
        tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
    }
    
    public func appendItems(items: [FOTableItem], toSectionAtIndex sectionIndex: Int) {
        if let section = dataSource.sectionAtIndex(sectionIndex) {
            var location = tableView.numberOfRowsInSection(sectionIndex)
            
            if dataSource.pagingIndexPath(section) != nil {
                location--
            }
            
            let indexPaths = NSIndexPath.indexPathsForItemsInRange(NSMakeRange(location, items.count), section: sectionIndex)
            insertItems(items, indexPaths: indexPaths)
        }
    }
    
    public func clearAllItems() {
        let indexes = NSIndexSet(indexesInRange: NSMakeRange(0, dataSource.numberOfSectionsInTableView(tableView)))
        deleteSectionsAtIndexes(indexes)
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
        if let indexPaths = tableView.indexPathsForVisibleRows {
            for indexPath in indexPaths {
                if let cell = tableView.cellForRowAtIndexPath(indexPath), item = dataSource.itemAtIndexPath(indexPath) {
                    item.configure(cell, tableView: tableView, indexPath: indexPath)
                }
            }
        }
    }

    // MARK: Paging
    
    // Implemented by subclass
    public func nextPageForSection(section: Int, tableView: UITableView) {
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
            if let indexPath = dataSource.lastIndexPathForSectionIndex(notPaging.firstIndex) {
                let rect = tableView.rectForRowAtIndexPath(indexPath)
                let distance = CGRectGetMaxY(rect) - tableView.contentOffset.y - tableView.frame.size.height
                
                if distance < pagingThreshold {
                    queueUpdate({
                        [weak self] in
                        self?.setPagingState(.Paging, sectionIndex: notPaging.firstIndex)
                    }, completion: {
                        [weak self] in
                        if let tableView = self?.tableView {
                            self?.nextPageForSection(notPaging.firstIndex, tableView: tableView)
                        }
                    })
                }
            }
        }
    }
    
}
