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
            self.insertSections([self.sectionAlpha1()], indexes: IndexSet(integer: 0))
//            self.insertSections([self.sectionBeta1()], indexes: IndexSet(integer: 1))
        })
        
        queueUpdate({
            let newSections = [
                self.sectionAlpha2(),
//                self.sectionBeta2(),
            ]
            let startPaths = self.dataSource.statePaths()
            let endPaths = self.dataSource.statePaths(sections: newSections)
            let updater = FOCollectionUpdater(from: startPaths, to: endPaths)
            
            let update0 = updater.update(index: 0)
            let update1 = updater.update(index: 1)
            
            if
                let deletions = update1.deletions,
                deletions.count > 0
            {
                self.deleteItemsAtIndexPaths(deletions.map{$0.indexPath})
            }
            
            if
                let insertions = update1.insertions,
                insertions.count > 0
            {
//                self.insertItems([], indexPaths: insertions.map{$0.indexPath})
            }
            
            if
                let moves = update1.moves,
                moves.count > 0
            {
                for move in moves {
                    self.tableView.moveRow(at: move.from.indexPath, to: move.to.indexPath)
                }
            }
            
            self.dataSource.clearAllItems(self.tableView)
            self.dataSource.insertSections(newSections, atIndexes: IndexSet(integer: 0), tableView: self.tableView, viewController: self)
            
            print("yello")
        })
    }
    
    func sectionAlpha1() -> FOTableSection {
        let section = FOTableSection()
        
        section.identifier = "Alpha"
        section.items = [
            TableCellItem(identifier: "A", color: .blue),
            TableCellItem(identifier: "B", color: .blue),
            TableCellItem(identifier: "C", color: .blue),
            TableCellItem(identifier: "D", color: .blue),
            TableCellItem(identifier: "E", color: .blue),
            TableCellItem(identifier: "F", color: .blue),
        ]
        
        return section
    }
    
    func sectionAlpha2() -> FOTableSection {
        let section = FOTableSection()
        
        section.identifier = "Alpha"
        section.items = [
            TableCellItem(identifier: "D", color: .blue),
            TableCellItem(identifier: "B", color: .blue),
            TableCellItem(identifier: "F", color: .blue),
            TableCellItem(identifier: "C", color: .blue),
            TableCellItem(identifier: "A", color: .blue),
            TableCellItem(identifier: "E", color: .blue),
        ]
        
        return section
    }
    
    func sectionBeta1() -> FOTableSection {
        let section = FOTableSection()
        
        section.identifier = "Beta"
        section.items = [
            TableCellItem(identifier: "D", color: .green),
            TableCellItem(identifier: "E", color: .green),
            TableCellItem(identifier: "F", color: .green),
        ]
        
        return section
    }
    
    func sectionBeta2() -> FOTableSection {
        let section = FOTableSection()
        
        section.identifier = "Beta"
        section.items = [
            TableCellItem(identifier: "D", color: .green),
            TableCellItem(identifier: "F", color: .green),
            TableCellItem(identifier: "E", color: .green),
        ]
        
        return section
    }
    
    override func nextPageForSection(_ section: FOTableSection, tableView: UITableView) {
        print("\(#function)")
    }
    
}

