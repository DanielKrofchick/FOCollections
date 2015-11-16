//
//  FOTableViewController.swift
//  Figure1
//
//  Created by Daniel Krofchick on 2015-04-23.
//  Copyright (c) 2015 Movable Science. All rights reserved.
//

import UIKit

public class FOTableViewController: UITableViewController {

    public let dataSource = FOTableViewDataSource()
    public var pagingThreshold = CGFloat(1000)
    private var cellSizeCache = [String: CGFloat]()
    private var layoutCellCache = [String: UITableViewCell]()
    private var pagingTimer: NSTimer?
    var queue = NSOperationQueue()                              // All table UI updates are performed on this queue to serialize animations
    public var updateDuration = NSTimeInterval(0.5)
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        queue.qualityOfService = NSQualityOfService.UserInitiated
        queue.name = "TableViewController"
        queue.maxConcurrentOperationCount = 1
        
        view.backgroundColor = UIColor.whiteColor()
        
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.dataSource = dataSource
        tableView.delegate = self
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
    
    // MARK: Utility
    
    func configurator(indexPath: NSIndexPath) -> FOTableConfiguratorProtocol? {
        return dataSource.configurator(indexPath)
    }
    
    func configuratorForSection(section: Int) -> FOTableConfiguratorProtocol? {
        return dataSource.configuratorForSection(section)
    }
    
    // MARK: Modification
    
    func tableUpdate(updates: (() -> ()), duration: NSTimeInterval, completion: (() -> ())?) {
        UIView.beginAnimations("FOTableViewController", context: nil)
        UIView.setAnimationDuration(duration)
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion?()
        }
        tableView.beginUpdates()
        updates()
        tableView.endUpdates()
        CATransaction.commit()
        UIView.commitAnimations()
    }

    public func performQueuedWork(work: (() -> ())) {
        queue.addOperation(NSBlockOperation(block: {
            work()
        }))
    }
    
    public func performQueuedBatchUpdates(updates: (() -> ()), completion: (() -> ())?) {
        queue.addOperation(FOCompletionOperation(work: { (operation) -> Void in
            self.tableUpdate(updates, duration: self.updateDuration, completion: { () -> () in
                completion?()
                operation.finish()
            })
        }, queue: dispatch_get_main_queue()))
    }
    
    // queued if completion block given
    public func insertSections(sections: [FOTableSection], indexes: NSIndexSet, completion: (() -> ())? = nil) {
        if completion != nil {
            performQueuedBatchUpdates({
                self.dataSource.insertSections(sections, atIndexes: indexes, tableView: self.tableView)
                self.tableView.insertSections(indexes, withRowAnimation: .Fade)
                }, completion: completion)
        } else {
            dataSource.insertSections(sections, atIndexes: indexes, tableView: self.tableView)
            tableView.insertSections(indexes, withRowAnimation: .Fade)
        }
    }
    
    // queued if completion block given
    public func deleteSectionsAtIndexes(indexes: NSIndexSet, completion: (() -> ())? = nil) {
        if completion != nil {
            performQueuedBatchUpdates({
                self.dataSource.deleteSectionsAtIndexes(indexes, tableView: self.tableView)
                self.tableView.deleteSections(indexes, withRowAnimation: .Fade)
                }, completion: completion)
        } else {
            dataSource.deleteSectionsAtIndexes(indexes, tableView: self.tableView)
            tableView.deleteSections(indexes, withRowAnimation: .Fade)
        }
    }
    
    // queued if completion block given
    public func insertItems(items: [FOTableItem], indexPaths: [NSIndexPath], completion: (() -> ())? = nil) {
        if completion != nil {
            performQueuedBatchUpdates({
                self.dataSource.insertItems(items, atIndexPaths: indexPaths, tableView: self.tableView)
                self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
                }, completion: completion)
        } else {
            dataSource.insertItems(items, atIndexPaths: indexPaths, tableView: self.tableView)
            tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
        }
    }
    
    // queued if completion block given
    public func deleteItemsAtIndexPaths(indexPaths: [NSIndexPath], completion: (() -> ())? = nil) {
        if completion != nil {
            performQueuedBatchUpdates({
                self.dataSource.deleteItemsAtIndexPaths(indexPaths, tableView: self.tableView)
                self.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
                }, completion: completion)
        } else {
            dataSource.deleteItemsAtIndexPaths(indexPaths, tableView: self.tableView)
            tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
        }
    }
    
    // queued
    public func loadSections(sections: [FOTableSection], completion: (() -> ())?) {
        performQueuedBatchUpdates({
            let deleteIndexes = NSIndexSet(indexesInRange: NSMakeRange(0, self.dataSource.numberOfSectionsInTableView(self.tableView)))
            let insertIndexes = NSIndexSet(indexesInRange: NSMakeRange(0, sections.count))
            
            self.deleteSectionsAtIndexes(deleteIndexes)
            self.insertSections(sections, indexes: insertIndexes)
        }, completion: completion)
    }
    
    // queued
    public func setPagingState(pagingState: PagingState, sectionIndex: Int, completion: (() -> ())?) {
        performQueuedBatchUpdates({
            if let section = self.dataSource.sectionAtIndex(sectionIndex) {
                section.pagingState = pagingState
                
                if pagingState == .Paging && !self.pagingItemExistsForSection(section) {
                    // ADD
                    if let lastIndexPath = self.dataSource.afterLastIndexPathForSectionIndex(0) {
                        self.insertItems([self.pagingItemForSection(section)], indexPaths: [lastIndexPath])
                    }
                } else if (pagingState == .NotPaging || pagingState == .Disabled || pagingState == .Finished) && self.pagingItemExistsForSection(section) {
                    // REMOVE
                    if let lastIndexPath = self.dataSource.lastIndexPathForSectionIndex(0) {
                        self.deleteItemsAtIndexPaths([lastIndexPath])
                    }
                }
            }
        }, completion: completion)
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
        performQueuedBatchUpdates({
            if self.dataSource.sectionsForPagingState(.Paging).count > 0 {
                return
            }
            
            let notPaging = self.dataSource.sectionsForPagingState(.NotPaging)
            
            if notPaging.count > 0 {
                if let indexPath = self.dataSource.lastIndexPathForSectionIndex(notPaging.firstIndex) { 
                    let rect = self.tableView.rectForRowAtIndexPath(indexPath)
                    let distance = CGRectGetMaxY(rect) - (self.tableView?.contentOffset.y)! - (self.tableView?.frame.size.height)!
                        
                    if distance < self.pagingThreshold {
                        self.setPagingState(.Paging, sectionIndex: notPaging.firstIndex, completion: { (finished) -> () in
                            self.nextPageForSection(notPaging.firstIndex, tableView: self.tableView)
                        })
                    }
                }
            }
        }, completion: nil)
    }
    
    let pagingItemReuseIdentifier = "pagingItemResuseIdentifier"
    
    public func pagingItemForSection(section: FOTableSection) -> FOTableItem {
        let item = FOTableItem()
        
        item.data = nil
        item.identifier = "pagingItem-\(section)"
        item.reuseIdentifier = pagingItemReuseIdentifier
        item.cellClass = UITableViewCell.self
        item.configurator = FOTablePagingConfigurator()
        
        return item
    }
    
    func pagingItemExistsForSection(section: FOTableSection) -> Bool {
        return section.items?.filter({$0.reuseIdentifier == pagingItemReuseIdentifier}).first != nil
    }
    
}



