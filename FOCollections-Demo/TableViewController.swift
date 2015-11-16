//
//  TableViewController.swift
//  FOCollectionsExamples
//
//  Created by Daniel Krofchick on 2015-11-12.
//  Copyright © 2015 Figure1. All rights reserved.
//

import UIKit

class TableViewController: FOTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor.orangeColor()
        updateDuration = 0.5
        
        loadSections(sections(), completion: {print("done1")})
        insertSections(sections(), indexes: NSIndexSet(index: 0), completion: {print("done2")})
        insertItems([item()], indexPaths: [NSIndexPath(forItem: 0, inSection: 0)], completion: {print("done3")})
        insertItems([item()], indexPaths: [NSIndexPath(forItem: 0, inSection: 0)], completion: {print("done3")})
        insertItems([item()], indexPaths: [NSIndexPath(forItem: 0, inSection: 0)], completion: {print("done3")})
        deleteItemsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)], completion: {print("doneD")})
        deleteItemsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)], completion: {print("doneD")})
        deleteItemsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)], completion: {print("doneD")})
        loadSections(sections(), completion: {print("done4")})
    }
    
    func sections() -> [FOTableSection] {
        let section = self.section()

        section.items = [
            item(),
            item(),
        ]
        
        return [section]
    }
    
    func section() -> FOTableSection {
        let section = FOTableSection()
        
        section.identifier = NSUUID().UUIDString
        section.pagingState = .NotPaging
        section.configurator = FOTableSectionConfigurator()
        section.configurator?.item?.section = section

        return section
    }
    
    func item() -> FOTableItem {
        let item = FOTableItem()
        
        item.data = UIColor.greenColor()
        item.identifier = NSUUID().UUIDString
        item.reuseIdentifier = "itemReuseIdentifier"
        item.cellClass = UITableViewCell.self
        item.configurator = FOTableItemConfigurator()
        
        return item
    }
    
}
