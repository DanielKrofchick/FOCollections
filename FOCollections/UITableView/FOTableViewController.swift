//
//  FOTableViewController.swift
//  Figure1
//
//  Created by Daniel Krofchick on 2015-04-23.
//  Copyright (c) 2015 Movable Science. All rights reserved.
//

import UIKit
import Foundation

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
        let work = {
            self.dataSource.insertSections(sections, atIndexes: indexes, tableView: self.tableView)
            self.tableView.insertSections(indexes, withRowAnimation: .Fade)
        }
        
        if completion != nil {
            performQueuedBatchUpdates({work()}, completion: completion)
        } else {
            work()
        }
    }
    
    // queued if completion block given
    public func deleteSectionsAtIndexes(indexes: NSIndexSet, completion: (() -> ())? = nil) {
        let work = {
            self.dataSource.deleteSectionsAtIndexes(indexes, tableView: self.tableView)
            self.tableView.deleteSections(indexes, withRowAnimation: .Fade)
        }
        
        if completion != nil {
            performQueuedBatchUpdates({work()}, completion: completion)
        } else {
            work()
        }
    }
    
    // queued if completion block given
    public func insertItems(items: [FOTableItem], indexPaths: [NSIndexPath], completion: (() -> ())? = nil) {
        let work = {
            self.dataSource.insertItems(items, atIndexPaths: indexPaths, tableView: self.tableView)
            self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
        }
        
        if completion != nil {
            performQueuedBatchUpdates({work()}, completion: completion)
        } else {
            work()
        }
    }
    
    // queued if completion block given
    public func deleteItemsAtIndexPaths(indexPaths: [NSIndexPath], completion: (() -> ())? = nil) {
        let work = {
            self.dataSource.deleteItemsAtIndexPaths(indexPaths, tableView: self.tableView)
            self.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
        }
        
        if completion != nil {
            performQueuedBatchUpdates({work()}, completion: completion)
        } else {
            work()
        }
    }
    
    // queued if completion block given
    public func appendItems(items: [FOTableItem], toSectionAtIndex sectionIndex: Int, completion: (() -> ())? = nil) {
        let work = {
            let location = self.tableView(self.tableView, numberOfRowsInSection: sectionIndex)
            let indexPaths = NSIndexPath.indexPathsForItemsInRange(NSMakeRange(location, items.count), section: sectionIndex)
            self.insertItems(items, indexPaths: indexPaths)
        }
        
        if completion != nil {
            performQueuedBatchUpdates({work()}, completion: completion)
        } else {
            work()
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
    
    
    public func pagingItemForSection(section: FOTableSection) -> FOTableItem {
        return FOTablePagingItem(section: section)
    }
    
    func pagingItemExistsForSection(section: FOTableSection) -> Bool {
        return section.items?.filter({$0.reuseIdentifier == tablePagingItemReuseIdentifier}).first != nil
    }
    
}



