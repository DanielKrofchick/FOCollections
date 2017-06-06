//
//  TableViewController.swift
//  FOCollectionsExamples
//
//  Created by Daniel Krofchick on 2015-11-12.
//  Copyright © 2015 Figure1. All rights reserved.
//

import UIKit

class TableViewController: FOTableViewController {
    
    let refresh = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor.orange
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(TableViewController.play))
        
        play()
    }
    
    func play() {
        queueUpdate({
            self.clearAllItems()
        })
        
        let sections1 = [
            self.section("A", identifiers: ["a1", "a2"], color: .blue),
            self.section("C", identifiers: ["c1", "c2", "c3"], color: .cyan),
            self.section("F", identifiers: ["f1", "f2"], color: .brown),
            self.section("X", identifiers: ["x1", "x2", "x3", "x4"], color: .purple),
            self.section("B", identifiers: ["b1"], color: .green),
            ]
        let sections2 = [
            self.section("Z", identifiers: ["z1"], color: .yellow),
            self.section("X", identifiers: ["x3", "x4", "x1"], color: .purple),
            self.section("A", identifiers: ["a1"], color: .blue),
            self.section("F", identifiers: ["f1", "f2", "x2", "f3"], color: .brown),
            ]
        
        queueUpdate({
            self.insertSections(sections1, indexes: IndexSet(integersIn: 0..<sections1.count))
        })
        
        queueUpdate({
            let startPaths = self.dataSource.statePaths()
            let endPaths = self.dataSource.statePaths(sections: sections2)
            let updater = FOCollectionUpdater(from: startPaths, to: endPaths)
            
            let update0 = updater.update(index: 0)
            
            self.updateSections(update: update0)
            
            let transformed = self.transform(fromSections: sections1, toSections: sections2, update: update0)
            
            _ = self.dataSource.clearAllItems(self.tableView)
            self.dataSource.insertSections(transformed, atIndexes: IndexSet(integersIn: 0..<transformed.count), tableView: self.tableView, viewController: self)
            
            self.refreshVisibleCells()
        })
        
        queueUpdate({
            let startPaths = self.dataSource.statePaths()
            let endPaths = self.dataSource.statePaths(sections: sections2)
            let updater = FOCollectionUpdater(from: startPaths, to: endPaths)
            
            let update1 = updater.update(index: 1)
            
            self.updateItems(update: update1)
            
            _ = self.dataSource.clearAllItems(self.tableView)
            self.dataSource.insertSections(sections2, atIndexes: IndexSet(integersIn: 0..<sections2.count), tableView: self.tableView, viewController: self)
            
            self.refreshVisibleCells()
        })
    }
    
    func transform(fromSections: [FOTableSection], toSections: [FOTableSection], update: Update) -> [FOTableSection] {
        func index(path: StatePath, in sections: [FOTableSection]) -> Int? {
            return sections.index(where: {
                (section) -> Bool in
                section.identifier == path.identifierPath.identifiers[0]
            })
        }
        
        func rearrange<T>(array: Array<T>, fromIndex: Int, toIndex: Int) -> Array<T> {
            var arr = array
            let element = arr.remove(at: fromIndex)
            arr.insert(element, at: toIndex)
            
            return arr
        }
        
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
    
    func updateSections(update: Update) {
        if
            let deletions = update.deletions,
            deletions.count > 0
        {
            tableView.deleteSections(IndexSet(deletions.map{$0.indexPath[0]}), with: .automatic)
        }
        
        if
            let insertions = update.insertions,
            insertions.count > 0
        {
            tableView.insertSections(IndexSet(insertions.map{$0.indexPath[0]}), with: .automatic)
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
    
    func updateItems(update: Update) {
        if
            let deletions = update.deletions,
            deletions.count > 0
        {
            tableView.deleteRows(at: deletions.map{$0.indexPath}, with: .automatic)
        }
        
        if
            let insertions = update.insertions,
            insertions.count > 0
        {
            tableView.insertRows(at: insertions.map{$0.indexPath}, with: .automatic)
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
    
    func findItem(sections: [FOTableSection], identifier: String) -> FOTableItem? {
        for section in sections {
            if let items = section.items {
                for item in items {
                    if item.identifier == identifier {
                        return item
                    }
                }
            }
        }
        
        return nil
    }
    
    func section(_ sectionIdentifier: String, identifiers: [String], color: UIColor) -> FOTableSection {
        let section = FOTableSection()
        
        section.identifier = sectionIdentifier
        section.items = identifiers.map{TableCellItem(identifier: $0, color: color)}
        
        return section
    }
    
    //    func sectionAlpha1() -> FOTableSection {
    //        let section = FOTableSection()
    //
    //        section.identifier = "Alpha"
    //        section.items = [
    //            TableCellItem(identifier: "A", color: .blue),
    //            TableCellItem(identifier: "B", color: .blue),
    //            TableCellItem(identifier: "C", color: .blue),
    //            TableCellItem(identifier: "D", color: .blue),
    //            TableCellItem(identifier: "E", color: .blue),
    //            TableCellItem(identifier: "F", color: .blue),
    //        ]
    //
    //        return section
    //    }
    //
    //    func sectionAlpha2() -> FOTableSection {
    //        let section = FOTableSection()
    //
    //        section.identifier = "Alpha"
    //        section.items = [
    //            TableCellItem(identifier: "F", color: .blue),
    //            TableCellItem(identifier: "A", color: .blue),
    //            TableCellItem(identifier: "G", color: .blue),
    //            TableCellItem(identifier: "D", color: .blue),
    //            TableCellItem(identifier: "C", color: .blue),
    //            TableCellItem(identifier: "X", color: .blue),
    //
    //        ]
    //
    //        return section
    //    }
    
    override func nextPageForSection(_ section: FOTableSection, tableView: UITableView) {
        print("\(#function)")
    }
    
}

