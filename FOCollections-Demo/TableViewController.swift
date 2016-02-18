//
//  TableViewController.swift
//  FOCollectionsExamples
//
//  Created by Daniel Krofchick on 2015-11-12.
//  Copyright © 2015 Figure1. All rights reserved.
//

import UIKit

class TableViewController: FOTableViewController {
    
    let refresh = UIButton(type: .System)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor.orangeColor()
        updateDuration = 0.5
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "play")
        
        play()
    }
    
    func play() {
        queueUpdate({[weak self] in self?.clearAllItems()})
        
        queueUpdate({[weak self] in self?.insertSections([self!.section()], indexes: NSIndexSet(index: 0))})
        queueUpdate({[weak self] in self?.deleteSectionsAtIndexes(NSIndexSet(index: 0))})
        queueUpdate({[weak self] in self?.insertSections([self!.section(UIColor.brownColor())], indexes: NSIndexSet(index: 0))})
        queueUpdate({[weak self] in self?.insertItems([self!.item(UIColor.yellowColor())], indexPaths: [NSIndexPath(forItem: 0, inSection: 0)])})
        queueUpdate({[weak self] in self?.deleteItemsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)])})
        queueUpdate({[weak self] in self?.appendItems(self!.items(UIColor.purpleColor(), items: 3), toSectionAtIndex: 0)})
        queueUpdate({[weak self] in self?.setPagingState(.Paging, sectionIndex: 0)})
        queueUpdate({[weak self] in self?.setPagingState(.Disabled, sectionIndex: 0)})
        queueUpdate({[weak self] in self?.setPagingState(.Paging, sectionIndex: 0)})
        queueUpdate({[weak self] in self?.setPagingState(.Finished, sectionIndex: 0)})
        queueUpdate({[weak self] in self?.setPagingState(.NotPaging, sectionIndex: 0)})
    }
    
    func section(color: UIColor = UIColor.blueColor(), items: Int = 4) -> FOTableSection {
        let section = FOTableSection()
        
        section.identifier = NSUUID().UUIDString
        section.pagingState = .Disabled
        section.items = self.items(color, items: items)
        
        return section
    }
    
    func items(color: UIColor = UIColor.blueColor(), items: Int = 1) -> [FOTableItem] {
        var r = [FOTableItem]()
        
        for _ in 0...items - 1 {
            r.append(item(color))
        }
        
        return r
    }
    
    func item(color: UIColor = UIColor.blueColor()) -> FOTableItem {
        let item = TableCellItem()
        
        item.data = color
        item.identifier = NSUUID().UUIDString
        item.reuseIdentifier = "itemReuseIdentifier"
        item.cellClass = UITableViewCell.self
        
        return item
    }

}

