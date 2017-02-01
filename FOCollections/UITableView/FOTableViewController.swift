//
//  FOTableViewController.swift
//  Figure1
//
//  Created by Daniel Krofchick on 2015-04-23.
//  Copyright (c) 2015 Movable Science. All rights reserved.
//

import UIKit

open class FOTableViewController: UIViewController, UITableViewDelegate {
    
    open var tableView: UITableView!
    open let dataSource = FOTableViewDataSource()
    open var pagingThreshold = CGFloat(1000)
    var cellSizeCache = [String: CGFloat]()
    var layoutCellCache = [String: UITableViewCell]()
    var pagingTimer: Timer?
    open var queue = OperationQueue()                              // All table UI updates are performed on this queue to serialize animations
    open var clearsSelectionOnViewWillAppear = true
    open var clearCellInsets = false
    open var defaultSeparatorInset = UIEdgeInsets.zero                // Preserve access to insets for cell layout purposes when setting 'clearCellInsets' = true
    
    public convenience init(frame: CGRect, style: UITableViewStyle) {
        self.init(nibName: nil, bundle: nil)
        
        createTableView(frame: frame, style: style)
        privateInit()
    }
    
    required override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        privateInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        privateInit()
    }
    
    func privateInit() {
        queue.qualityOfService = QualityOfService.userInitiated
        queue.name = "FOTableViewController"
        queue.maxConcurrentOperationCount = 1
        queue.isSuspended = true
        
        if tableView == nil {
            createTableView()
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        tableView.backgroundColor = UIColor.white
        tableView.dataSource = dataSource
        tableView.delegate = self
        view.addSubview(tableView)
        
        defaultSeparatorInset = tableView.separatorInset
        
        queue.isSuspended = false
    }
    
    fileprivate func createTableView(frame: CGRect = CGRect.zero, style: UITableViewStyle = .plain) {
        tableView = UITableView(frame: CGRect.zero, style: style)
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
        
        if clearCellInsets {
            tableView.layoutMargins = UIEdgeInsets.zero
            tableView.separatorInset = UIEdgeInsets.zero
        }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startPagingTimer()
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        stopPagingTimer()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if clearsSelectionOnViewWillAppear {
            if let indexPaths = tableView.indexPathsForSelectedRows {
                for indexPath in indexPaths {
                    tableView.deselectRow(at: indexPath, animated: animated)
                }
            }
        }
    }
    
    override open func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        cellSizeCache.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    // MARK: Modification
    
    func tableUpdate(_ update: (() -> ()), completion: (() -> ())?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion?()
        }
        tableView.beginUpdates()
        update()
        tableView.endUpdates()
        CATransaction.commit()
    }
    
    open func queueUpdate(_ update: @escaping (() -> ()), completion: (() -> ())? = nil) {
        queue.addOperation(FOCompletionOperation(work: {[weak self] (operation) -> Void in
            if self == nil {
                operation.finish()
                return
            }
            
            self!.tableUpdate(update, completion: { () -> () in
                completion?()
                operation.finish()
            })
            }, queue: DispatchQueue.main))
    }
    
    open func queueWork(_ work: @escaping (() -> ())) {
        queue.addOperation(BlockOperation(block: work))
    }
    
    open func insertSections(_ sections: [FOTableSection], indexes: IndexSet, animation: UITableViewRowAnimation = .fade) {
        dataSource.insertSections(sections, atIndexes: indexes, tableView: tableView, viewController: self)
        tableView.insertSections(indexes, with: animation)
    }
    
    open func deleteSectionsAtIndexes(_ indexes: IndexSet, animation: UITableViewRowAnimation = .fade) {
        dataSource.deleteSectionsAtIndexes(indexes, tableView: tableView)
        tableView.deleteSections(indexes, with: animation)
    }
    
    open func insertItems(_ items: [FOTableItem], indexPaths: [IndexPath], animation: UITableViewRowAnimation = .fade) {
        dataSource.insertItems(items, atIndexPaths: indexPaths, tableView: tableView, viewController: self)
        tableView.insertRows(at: indexPaths, with: animation)
    }
    
    open func deleteItemsAtIndexPaths(_ indexPaths: [IndexPath], animation: UITableViewRowAnimation = .fade) {
        dataSource.deleteItemsAtIndexPaths(indexPaths, tableView: tableView)
        tableView.deleteRows(at: indexPaths, with: animation)
    }
    
    open func appendItems(_ items: [FOTableItem], toSectionAtIndex sectionIndex: Int, animation: UITableViewRowAnimation = .fade) {
        if let indexPaths = dataSource.appendItems(items, toSectionAtIndex: sectionIndex, tableView: tableView, viewController: self) {
            tableView.insertRows(at: indexPaths, with: animation)
        }
    }
    
    open func prependItems(_ items: [FOTableItem], toSectionAtIndex sectionIndex: Int, animation: UITableViewRowAnimation = .fade) {
        if let indexPaths = dataSource.prependItems(items, toSectionAtIndex: sectionIndex, tableView: tableView, viewController: self) {
            tableView.insertRows(at: indexPaths, with: animation)
        }
    }
    
    open func prependItemsWithFixedOffset(_ items: [FOTableItem], toSectionAtIndex sectionIndex: Int) {
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
    
    open func clearAllItems(_ animation: UITableViewRowAnimation = .fade) {
        if let indexes = dataSource.clearAllItems(tableView) {
            tableView.deleteSections(indexes, with: animation)
        }
    }
    
    open func setPagingState(_ pagingState: PagingState, sectionIndex: Int, animation: UITableViewRowAnimation = .fade) {
        if let indexPath = dataSource.setPagingState(pagingState, sectionIndex: sectionIndex, tableView: tableView, viewController: self) {
            if pagingState == .paging {
                tableView.insertRows(at: [indexPath], with: animation)
            } else {
                tableView.deleteRows(at: [indexPath], with: animation)
            }
        }
    }
    
    func pagingIndexPath(_ section: FOTableSection) -> IndexPath? {
        let item = pagingItemForSection(section)
        
        return dataSource.indexPathsForItem(item).first
    }
    
    open func pagingItemForSection(_ section: FOTableSection) -> FOTableItem {
        return FOTablePagingItem(section: section)
    }
    
    open func refreshVisibleCells() {
        if let indexPaths = tableView.indexPathsForVisibleRows {
            for indexPath in indexPaths {
                if let cell = tableView.cellForRow(at: indexPath), let item = dataSource.itemAtIndexPath(indexPath) {
                    item.configure(cell, tableView: tableView, indexPath: indexPath)
                    cell.setNeedsLayout()
                }
            }
        }
    }
    
    // MARK: Paging
    
    // Implemented by subclass
    open func nextPageForSection(_ section: FOTableSection, tableView: UITableView) {
    }
    
    func startPagingTimer() {
        pagingTimer = Timer(timeInterval: 0.2, target: self, selector: #selector(FOTableViewController.checkForPaging), userInfo: nil, repeats: true)
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
        
        if let data = notPaging.first, let section = dataSource.sectionAtIndex(data) {
                if pagingIndexPath(section) == nil {
                    queueUpdate({
                        [weak self] in
                        self?.setPagingState(.paging, sectionIndex: data)
                        })
            }
        }
    }
    
    func triggerPagingIfNeeded() {
        if dataSource.sectionsForPagingState(.pagingAndFetching).first != NSNotFound {
            return
        }
        
        guard let sectionIndex = dataSource.sectionsForPagingState(.paging).first else {
            return
        }
        
        if sectionIndex == NSNotFound {
            return
        }
        
        if let section = dataSource.sectionAtIndex(sectionIndex) {
            if let indexPath = pagingIndexPath(section) {
                let rect = tableView.rectForRow(at: indexPath)
                var distance = CGFloat.greatestFiniteMagnitude
                
                if section.pagingDirection == .down {
                    distance = rect.minY - tableView.contentOffset.y - tableView.frame.size.height
                } else if section.pagingDirection == .up {
                    distance = tableView.contentOffset.y - rect.maxY
                }
                
                if distance < pagingThreshold {
                    section.pagingState = .pagingAndFetching
                    nextPageForSection(section, tableView: tableView)
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
