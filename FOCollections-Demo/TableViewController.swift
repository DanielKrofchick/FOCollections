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
        
        queueUpdate({
            let sections = [
                self.section("A", identifiers: ["a1"], color: .blue),
                self.section("F", identifiers: ["f1", "f2"], color: .brown),
                self.section("X", identifiers: ["x1", "x3", "x4"], color: .purple),
                self.section("B", identifiers: ["b1"], color: .green),
                ]
            
            self.insertSections(sections, indexes: IndexSet(integersIn: 0..<sections.count))
        })
        
        queueUpdate({
            let newSections = [
                self.section("Z", identifiers: ["z1"], color: .yellow),
                self.section("X", identifiers: ["x3", "x4", "x1"], color: .purple),
                self.section("A", identifiers: ["a1"], color: .blue),
                self.section("F", identifiers: ["f1", "f2"], color: .brown),
                ]
            let startPaths = self.dataSource.statePaths()
            let endPaths = self.dataSource.statePaths(sections: newSections)
            let updater = FOCollectionUpdater(from: startPaths, to: endPaths)
            
            //DO DELETIONS SEPERATELY if they are in a section move"
            
            let update0 = updater.update(index: 0)
            let update1 = updater.update(index: 1, filter: update0)
            
            self.updateSections(update: update0)
            self.updateItems(update: update1)
            
            _ = self.dataSource.clearAllItems(self.tableView)
            self.dataSource.insertSections(newSections, atIndexes: IndexSet(integersIn: 0..<newSections.count), tableView: self.tableView, viewController: self)
            
            print("yello")
        })
        
        //        queue.addOperation(FOCompletionOperation(work: {
        //            operation in
        //            let newSections = [
        //                self.section("Z", identifiers: ["z1"], color: .yellow),
        ////                self.section("F", identifiers: ["f1", "f2"], color: .brown),
        //                self.section("X", identifiers: ["x3", "x1", "x4", "x5"], color: .purple),
        //                self.section("A", identifiers: ["a1"], color: .blue),
        //                ]
        //            let startPaths = self.dataSource.statePaths()
        //            let endPaths = self.dataSource.statePaths(sections: newSections)
        //            let updater = FOCollectionUpdater(from: startPaths, to: endPaths)
        //
        //            //DO DELETIONS SEPERATELY if they are in a section move"
        //
        //            let update0 = updater.update(index: 0)
        //            let update1 = updater.update(index: 1, filter: update0)
        //
        //            self.tableView.beginUpdates()
        //            _ = self.dataSource.clearAllItems(self.tableView)
        //            self.dataSource.insertSections(newSections, atIndexes: IndexSet(integersIn: 0..<newSections.count), tableView: self.tableView, viewController: self)
        //
        ////            self.updateItems(update: update1)
        //
        ////            self.tableView.beginUpdates()
        //            self.updateSections(update: update0)
        ////            self.tableView.endUpdates()
        //            
        //            self.tableView.endUpdates()
        //            operation.finish()
        //        }, queue: DispatchQueue.main))
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

