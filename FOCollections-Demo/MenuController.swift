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
        
        tableView.backgroundColor = UIColor.orangeColor()
        updateDuration = 0.5
        
        loadData()
    }
    
    func loadData() {
        queueUpdate({[weak self] in self?.insertSections([self!.section()], indexes: NSIndexSet(index: 0))})
        queueUpdate({[weak self] in self?.insertItems([self!.tableItem(), self!.collectionItem()], indexPaths: [NSIndexPath(forItem: 0, inSection: 0), NSIndexPath(forItem: 1, inSection: 0)])})
    }
    
    func section() -> FOTableSection {
        let section = FOTableSection()
        
        section.identifier = NSUUID().UUIDString
        section.items = [FOTableItem]()
        
        return section
    }
    
    func item(color: UIColor = UIColor.blueColor(), text: String = "", identifier: String = NSUUID().UUIDString) -> FOTableItem {
        let item = MenuItem()
        
        item.data = [color, text]
        item.identifier = identifier
        item.reuseIdentifier = "itemReuseIdentifier"
        item.cellClass = UITableViewCell.self
        
        return item
    }
    
    func tableItem() -> FOTableItem {
        return item(UIColor.redColor(), text: "Table View", identifier: tableIdentifier)
    }

    func collectionItem() -> FOTableItem {
        return item(UIColor.greenColor(), text: "Collection View", identifier: collectionIdentifier)
    }
    
}

