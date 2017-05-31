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
                self.sectionAlpha1(),
                self.sectionBeta1(),
                self.sectionCappa1(),
                self.sectionDelta1(),
                self.sectionElta1(),
                self.sectionFelta1(),
                ]
            
            self.insertSections(sections, indexes: IndexSet(integersIn: 0..<sections.count))
        })
        
        queueUpdate({
            let newSections = [
                self.sectionFelta1(),
                self.sectionAlpha2(),
                self.sectionGamma1(),
                self.sectionDelta1(),
                self.sectionCappa1(),
                self.sectionXi1(),
                ]
            let startPaths = self.dataSource.statePaths()
            let endPaths = self.dataSource.statePaths(sections: newSections)
            let updater = FOCollectionUpdater(from: startPaths, to: endPaths)
            
            let update0 = updater.update(index: 0)
            let update1 = updater.update(index: 1, filter: update0)
            
            self.updateSections(update: update0)
            self.updateItems(update: update1)
            
            _ = self.dataSource.clearAllItems(self.tableView)
            self.dataSource.insertSections(newSections, atIndexes: IndexSet(integersIn: 0..<newSections.count), tableView: self.tableView, viewController: self)
            
            print("yello")
        })
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
    
    func sectionAlpha1() -> FOTableSection {
        let section = FOTableSection()
        
        section.identifier = "Alpha"
        section.items = [
            TableCellItem(identifier: "A", color: .blue),
        ]
        
        return section
    }
    
    func sectionAlpha2() -> FOTableSection {
        let section = FOTableSection()
        
        section.identifier = "Alpha"
        section.items = [
            TableCellItem(identifier: "A", color: .blue),
            TableCellItem(identifier: "A2", color: .blue),
        ]
        
        return section
    }
    
    func sectionBeta1() -> FOTableSection {
        let section = FOTableSection()
        
        section.identifier = "Beta"
        section.items = [
            TableCellItem(identifier: "B", color: .green),
        ]
        
        return section
    }
    
    func sectionCappa1() -> FOTableSection {
        let section = FOTableSection()
        
        section.identifier = "Cappa"
        section.items = [
            TableCellItem(identifier: "C", color: .red),
        ]
        
        return section
    }
    
    func sectionDelta1() -> FOTableSection {
        let section = FOTableSection()
        
        section.identifier = "Delta"
        section.items = [
            TableCellItem(identifier: "D", color: .yellow),
        ]
        
        return section
    }
    
    func sectionElta1() -> FOTableSection {
        let section = FOTableSection()
        
        section.identifier = "Elta"
        section.items = [
            TableCellItem(identifier: "E", color: .purple),
        ]
        
        return section
    }
    
    func sectionFelta1() -> FOTableSection {
        let section = FOTableSection()
        
        section.identifier = "Felta"
        section.items = [
            TableCellItem(identifier: "F", color: .brown),
        ]
        
        return section
    }
    
    func sectionGamma1() -> FOTableSection {
        let section = FOTableSection()
        
        section.identifier = "Gamma"
        section.items = [
            TableCellItem(identifier: "G", color: .cyan),
        ]
        
        return section
    }
    
    func sectionXi1() -> FOTableSection {
        let section = FOTableSection()
        
        section.identifier = "Xi"
        section.items = [
            TableCellItem(identifier: "X", color: .magenta),
        ]
        
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

