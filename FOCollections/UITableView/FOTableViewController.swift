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
        if dataSource.sectionsForPagingState(.pagingAndFetching).first != nil {
            return
        }
        
        guard let sectionIndex = dataSource.sectionsForPagingState(.paging).first else {
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

extension FOTableViewController {
    
    func animateUpdate(_ to: [FOTableSection], with animation: UITableViewRowAnimation = .automatic) {
        queue.addOperation(FOCompletionOperation(work: {
            [weak self] (operation) -> Void in
            if let this = self {
                // Update sections
                this.tableView.beginUpdates()
                
                let fromSections0 = this.dataSource.sections
                let fromPaths0 = this.dataSource.statePaths()
                let toPaths0 = this.dataSource.statePaths(sections: to)
                let updater0 = FOCollectionUpdater(from: fromPaths0, to: toPaths0)
                
                let update0 = updater0.update(index: 0)
                
                this.updateSections(update: update0, with: animation)
                
                let transformed = this.transform(fromSections: fromSections0, toSections: to, update: update0)
                
                _ = this.dataSource.clearAllItems(this.tableView)
                this.dataSource.insertSections(transformed, atIndexes: IndexSet(integersIn: 0..<transformed.count), tableView: this.tableView, viewController: this)
                
                this.tableView.endUpdates()
                
                CATransaction.begin()
                CATransaction.setCompletionBlock {
                    operation.finish()
                }
                
                // Update items
                this.tableView.beginUpdates()
                
                let fromPaths1 = this.dataSource.statePaths()
                let toPaths1 = this.dataSource.statePaths(sections: to)
                let updater1 = FOCollectionUpdater(from: fromPaths1, to: toPaths1)
                
                let update1 = updater1.update(index: 1)
                
                this.updateItems(update: update1, with: animation)
                
                _ = this.dataSource.clearAllItems(this.tableView)
                this.dataSource.insertSections(to, atIndexes: IndexSet(integersIn: 0..<to.count), tableView: this.tableView, viewController: this)
                
                this.tableView.endUpdates()
                this.refreshVisibleCells()
                CATransaction.commit()
            }
        }, queue: DispatchQueue.main))
    }
    
    fileprivate func transform(fromSections: [FOTableSection], toSections: [FOTableSection], update: Update) -> [FOTableSection] {
        var result = fromSections
        
        update.deletions?.forEach({
            path in
            if let index = index(path: path, in: result) {
                result.remove(at: index)
            }
        })
        
        update.insertions?.forEach({
            path in
            if let index = index(path: path, in: toSections) {
                let section = toSections[index]
                result.insert(section, at: index)
            }
        })
        
        update.moves?.forEach({
            move in
            if let fromIndex = index(path: move.from, in: result) {
                let toIndex = move.to.indexPath[0]
                result = rearrange(array: result, fromIndex: fromIndex, toIndex: toIndex)
            }
        })
        
        return result
    }
    
    fileprivate func index(path: StatePath, in sections: [FOTableSection]) -> Int? {
        return sections.index(where: {
            (section) -> Bool in
            section.identifier == path.identifierPath.identifiers[0]
        })
    }
    
    fileprivate func rearrange<T>(array: Array<T>, fromIndex: Int, toIndex: Int) -> Array<T> {
        var arr = array
        let element = arr.remove(at: fromIndex)
        arr.insert(element, at: toIndex)
        
        return arr
    }
    
    fileprivate func updateSections(update: Update, with animation: UITableViewRowAnimation) {
        if
            let deletions = update.deletions,
            deletions.count > 0
        {
            tableView.deleteSections(IndexSet(deletions.map{$0.indexPath[0]}), with: animation)
        }
        
        if
            let insertions = update.insertions,
            insertions.count > 0
        {
            tableView.insertSections(IndexSet(insertions.map{$0.indexPath[0]}), with: animation)
        }
        
        if
            let moves = update.moves,
            moves.count > 0
        {
            for move in moves {
                tableView.moveSection(move.from.indexPath[0], toSection: move.to.indexPath[0])
            }
        }
    }
    
    fileprivate func updateItems(update: Update, with animation: UITableViewRowAnimation) {
        if
            let deletions = update.deletions,
            deletions.count > 0
        {
            tableView.deleteRows(at: deletions.map{$0.indexPath}, with: animation)
        }
        
        if
            let insertions = update.insertions,
            insertions.count > 0
        {
            tableView.insertRows(at: insertions.map{$0.indexPath}, with: animation)
        }
        
        if
            let moves = update.moves,
            moves.count > 0
        {
            for move in moves {
                tableView.moveRow(at: move.from.indexPath, to: move.to.indexPath)
            }
        }
    }
    
}
