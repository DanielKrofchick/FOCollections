//
//  FOTableViewController.swift
//  Figure1
//
//  Created by Daniel Krofchick on 2015-04-23.
//  Copyright (c) 2015 Movable Science. All rights reserved.
//

import UIKit

public class FOTableViewController: UIViewController, UITableViewDelegate {

    public var tableView: UITableView!
    public let dataSource = FOTableViewDataSource()
    public var pagingThreshold = CGFloat(1000)
    var cellSizeCache = [String: CGFloat]()
    var layoutCellCache = [String: UITableViewCell]()
    var pagingTimer: NSTimer?
    public var queue = NSOperationQueue()                              // All table UI updates are performed on this queue to serialize animations
    
    public convenience init(frame: CGRect, style: UITableViewStyle) {
        self.init(nibName: nil, bundle: nil)
        
        createTableView(frame: frame, style: style)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        queue.qualityOfService = NSQualityOfService.UserInitiated
        queue.name = "FOTableViewController"
        queue.maxConcurrentOperationCount = 1
        
        if tableView == nil {
            createTableView()
        }
        
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.dataSource = dataSource
        tableView.delegate = self
        view.addSubview(tableView)
    }
    
    private func createTableView(frame frame: CGRect = CGRectZero, style: UITableViewStyle = .Plain) {
        tableView = UITableView(frame: CGRectZero, style: style)
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
        
        cellSizeCache.removeAll(keepCapacity: true)
        tableView.reloadData()
    }
        
    // MARK: Modification
    
    func tableUpdate(update: (() -> ()), completion: (() -> ())?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion?()
        }
        tableView.beginUpdates()
        update()
        tableView.endUpdates()
        CATransaction.commit()
    }

    public func queueUpdate(update: (() -> ()), completion: (() -> ())? = nil) {
        queue.addOperation(FOCompletionOperation(work: {[weak self] (operation) -> Void in
            if self == nil {
                operation.finish()
                return
            }
            
            self!.tableUpdate(update, completion: { () -> () in
                completion?()
                operation.finish()
            })
        }, queue: dispatch_get_main_queue()))
    }
    
    public func queueWork(work: (() -> ())) {
        queue.addOperation(NSBlockOperation(block: work))
    }
    
    public func insertSections(sections: [FOTableSection], indexes: NSIndexSet, animation: UITableViewRowAnimation = .Fade) {
        dataSource.insertSections(sections, atIndexes: indexes, tableView: tableView, viewController: self)
        tableView.insertSections(indexes, withRowAnimation: animation)
    }
    
    public func deleteSectionsAtIndexes(indexes: NSIndexSet, animation: UITableViewRowAnimation = .Fade) {
        dataSource.deleteSectionsAtIndexes(indexes, tableView: tableView)
        tableView.deleteSections(indexes, withRowAnimation: animation)
    }
    
    public func insertItems(items: [FOTableItem], indexPaths: [NSIndexPath], animation: UITableViewRowAnimation = .Fade) {
        dataSource.insertItems(items, atIndexPaths: indexPaths, tableView: tableView, viewController: self)
        tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: animation)
    }
    
    public func deleteItemsAtIndexPaths(indexPaths: [NSIndexPath], animation: UITableViewRowAnimation = .Fade) {
        dataSource.deleteItemsAtIndexPaths(indexPaths, tableView: tableView)
        tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: animation)
    }
    
    public func appendItems(items: [FOTableItem], toSectionAtIndex sectionIndex: Int, animation: UITableViewRowAnimation = .Fade) {
        if let indexPaths = dataSource.appendItems(items, toSectionAtIndex: sectionIndex, tableView: tableView, viewController: self) {
            tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: animation)
        }
    }

    public func prependItems(items: [FOTableItem], toSectionAtIndex sectionIndex: Int, animation: UITableViewRowAnimation = .Fade) {
        if let indexPaths = dataSource.prependItems(items, toSectionAtIndex: sectionIndex, tableView: tableView, viewController: self) {
            tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: animation)
        }
    }
    
    public func prependItemsWithFixedOffset(items: [FOTableItem], toSectionAtIndex sectionIndex: Int) {
        if let _ = dataSource.prependItems(items, toSectionAtIndex: sectionIndex, tableView: tableView, viewController: self) {
            let iSize = tableView.contentSize
            
            tableView.reloadData()
            
            let fSize = tableView.contentSize
            let fOffset = tableView.contentOffset
            
            // Force layout to prevent tableView from setting offset after we do here
            tableView.layoutIfNeeded()
            tableView.contentOffset = CGPoint(x: fOffset.x, y: fOffset.y + fSize.height - iSize.height)
        }
    }
    
    public func clearAllItems(animation: UITableViewRowAnimation = .Fade) {
        if let indexes = dataSource.clearAllItems(tableView) {
            tableView.deleteSections(indexes, withRowAnimation: animation)
        }
    }
    
    public func setPagingState(pagingState: PagingState, sectionIndex: Int, animation: UITableViewRowAnimation = .Fade) {
        if let indexPath = dataSource.setPagingState(pagingState, sectionIndex: sectionIndex, tableView: tableView, viewController: self) {
            if pagingState == .Paging {
                tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: animation)
            } else {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: animation)
            }
        }
    }
    
    func pagingIndexPath(section: FOTableSection) -> NSIndexPath? {
        let item = pagingItemForSection(section)
        
        return dataSource.indexPathsForItem(item).first
    }
    
    public func pagingItemForSection(section: FOTableSection) -> FOTableItem {
        return FOTablePagingItem(section: section)
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
    public func nextPageForSection(section: FOTableSection, tableView: UITableView) {
    }
    
    func startPagingTimer() {
        pagingTimer = NSTimer(timeInterval: 0.2, target: self, selector: #selector(FOTableViewController.checkForPaging), userInfo: nil, repeats: true)
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
            if let indexPath = pagingIndexPath(section) {
                let rect = tableView.rectForRowAtIndexPath(indexPath)
                var distance = CGFloat.max
                
                if section.pagingDirection == .Down {
                    distance = CGRectGetMinY(rect) - tableView.contentOffset.y - tableView.frame.size.height
                } else if section.pagingDirection == .Up {
                    distance = tableView.contentOffset.y - CGRectGetMaxY(rect)
                }
                
                if distance < pagingThreshold {
                    section.pagingState = .PagingAndFetching
                    nextPageForSection(section, tableView: tableView)
                }
            }
        }
    }
    
    public func clearCellSizeCache(keepCapacity: Bool = true) {
        cellSizeCache.removeAll(keepCapacity: keepCapacity)
    }
    
}
