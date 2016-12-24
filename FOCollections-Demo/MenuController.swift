//
//  MenuController.swift
//  FOCollections
//
//  Created by Daniel Krofchick on 2016-02-17.
//  Copyright © 2016 Figure1. All rights reserved.
//

import UIKit

let tableIdentifier = "tableIdentifier"
let collectionIdentifier = "collectionIdentifier"

class MenuController: FOTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor.orange
        
        loadData()
    }
    
    func loadData() {
        queueUpdate({[weak self] in self?.insertSections([self!.section()], indexes: IndexSet(integer: 0))})
        queueUpdate({[weak self] in self?.insertItems([self!.tableItem(), self!.collectionItem()], indexPaths: [IndexPath(item: 0, section: 0), IndexPath(item: 1, section: 0)])})
    }
    
    func section() -> FOTableSection {
        let section = FOTableSection()
        
        section.identifier = UUID().uuidString
        section.items = [FOTableItem]()
        
        return section
    }
    
    func item(_ color: UIColor = UIColor.blue, text: String = "", identifier: String = UUID().uuidString) -> FOTableItem {
        let item = MenuItem()
        
        item.data = ["color": color, "text": text]
        item.identifier = identifier
        item.reuseIdentifier = "itemReuseIdentifier"
        item.cellClass = UITableViewCell.self
        
        return item
    }
    
    func tableItem() -> FOTableItem {
        return item(UIColor.red, text: "Table View", identifier: tableIdentifier)
    }

    func collectionItem() -> FOTableItem {
        return item(UIColor.green, text: "Collection View", identifier: collectionIdentifier)
    }
    
}

