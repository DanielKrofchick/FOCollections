//
//  FOTableViewController+Updater.swift
//  FOCollections
//
//  Created by Daniel Krofchick on 2017-06-30.
//  Copyright © 2017 Figure1. All rights reserved.
//

import UIKit

extension FOTableViewController {
    
    open func animateUpdate(_ to: [FOTableSection], with animation: UITableViewRowAnimation = .automatic, duration: TimeInterval? = nil, completion: (() -> ())? = nil) {
        queue.addOperation(FOCompletionOperation(work: {
            [weak self] (operation) -> Void in
            if let duration = duration {
                UIView.animate(withDuration: duration, animations: {
                    self?.doAnimateUpdate(to, animation: animation, completion: completion, operation: operation)
                })
            } else {
                self?.doAnimateUpdate(to, animation: animation, completion: completion, operation: operation)
            }
        }, queue: DispatchQueue.main))
    }
    
    private func doAnimateUpdate(_ to: [FOTableSection], animation: UITableViewRowAnimation, completion: (() -> ())?, operation: FOCompletionOperation) {
        //let date = Date()
        var doneCount = 0
        
        func processDone() {
            doneCount += 1
            
            if doneCount == 2 {
                operation.finish()
                completion?()
            }
        }
        
        func doUpdateSections() {
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                //print("first", Date().timeIntervalSinceReferenceDate - date.timeIntervalSinceReferenceDate)
                processDone()
            }
            
            tableView.beginUpdates()
            
            let fromSections0 = dataSource.sections
            let fromPaths0 = dataSource.statePaths()
            let toPaths0 = dataSource.statePaths(sections: to)
            let updater0 = CollectionUpdater(from: fromPaths0, to: toPaths0)
            let update0 = updater0.update(index: 0)
            
            updateSections(update: update0, with: animation)
            
            let transformed = transform(fromSections: fromSections0, toSections: to, update: update0)
            
            _ = dataSource.clearAllItems(tableView)
            dataSource.insertSections(transformed, atIndexes: IndexSet(integersIn: 0..<transformed.count), tableView: tableView, viewController: self)
            
            tableView.endUpdates()
            
            CATransaction.commit()
        }
        
        func doUpdateItems() {
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                //print("second", Date().timeIntervalSinceReferenceDate - date.timeIntervalSinceReferenceDate)
                processDone()
            }
            
            tableView.beginUpdates()
            
            let fromPaths1 = dataSource.statePaths()
            let toPaths1 = dataSource.statePaths(sections: to)
            let updater1 = CollectionUpdater(from: fromPaths1, to: toPaths1)
            let update1 = updater1.update(index: 1)
            
            updateItems(update: update1, with: animation)
            
            _ = dataSource.clearAllItems(tableView)
            dataSource.insertSections(to, atIndexes: IndexSet(integersIn: 0..<to.count), tableView: tableView, viewController: self)
            
            tableView.endUpdates()
            
            CATransaction.commit()
        }
        
        doUpdateSections()
        doUpdateItems()
        refreshVisibleCells()
    }
    
    fileprivate func transform(fromSections: [FOTableSection], toSections: [FOTableSection], update: Update) -> [FOTableSection] {
        var result = fromSections
        let iIdentifiers: [String] = update.insertions != nil ? itemIdentifiers(fromSections) : [String]()
        
        update.deletions?.forEach({
            path in
            if let index = index(path: path, in: result) {
                result.remove(at: index)
            }
        })
        
        update.insertions?.forEach({
            path in
            if let index = index(path: path, in: toSections) {
                let section = removeDuplicateItems(toSections[index], itemIdentifiers: iIdentifiers)
                result.insert(section, at: index)
            }
        })
        
        toSections.enumerated().forEach {
            (s) in
            if
                let index = result.index(of: s.element),
                index != s.offset
            {
                result.move(at: index, to: s.offset)
            }
        }
        
        return result
    }
    
    private func itemIdentifiers(_ sections: [FOTableSection]) -> [String] {
        return sections.reduce([String](), { (sResult, section) -> [String] in
            if let items = section.items {
                return sResult + items.reduce([String](), { (iResult, item) -> [String] in
                    if let identifier = item.identifier {
                        return iResult + [identifier]
                    } else {
                        return iResult
                    }
                })
            } else {
                return sResult
            }
        })
    }
    
    private func itemIdentifiers(_ section: FOTableSection) -> [String] {
        if let items = section.items {
            return items.reduce([String](), { (iResult, item) -> [String] in
                if let identifier = item.identifier {
                    return iResult + [identifier]
                } else {
                    return iResult
                }
            })
        } else {
            return [String]()
        }
    }
    
    // This covers an edge case when an item is moved into an inserted section. The transfromed intermediate state
    // will have two copies of the item, one in the original section and one in the inserted. This fixes that.
    // One important caveate of this fix is that the section must be copied to alter it's items. This is normally fine
    // since onlly the intermediate state uses the copy, the final uses the original. But if FOTableSection
    // has custom display logic, there may be UI issues until .copy() is properly implemented for FOTableSection.
    private func removeDuplicateItems(_ section: FOTableSection, itemIdentifiers: [String]) -> FOTableSection {
        let sIdentifiers = self.itemIdentifiers(section)
        let iIdentifiers = Array(itemIdentifiers)
        let duplicates = iIdentifiers.filter{sIdentifiers.contains($0)}
        var result = section
        
        if
            !duplicates.isEmpty,
            let section = section.copy() as? FOTableSection
        {
            result = section
            result.items = result.items?.filter({
                item in
                if let identifier = item.identifier {
                    return !duplicates.contains(identifier)
                } else {
                    return true
                }
            })
        }
        
        return result
    }
    
    fileprivate func index(path: StatePath, in sections: [FOTableSection]) -> Int? {
        return sections.index(where: {
            (section) -> Bool in
            section.identifier == path.identifierPath.identifiers[0]
        })
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

private extension Array {
    mutating func move(at oldIndex: Int, to newIndex: Int) {
        insert(remove(at: oldIndex), at: newIndex)
    }
}
