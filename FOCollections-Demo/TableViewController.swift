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
        
        animateUpdate(sections2)
    }
    
    func section(_ sectionIdentifier: String, identifiers: [String], color: UIColor) -> FOTableSection {
        let section = FOTableSection()
        
        section.identifier = sectionIdentifier
        section.items = identifiers.map{TableCellItem(identifier: $0, color: color)}
        
        return section
    }
    
    override func nextPageForSection(_ section: FOTableSection, tableView: UITableView) {
        print("\(#function)")
    }
    
}

