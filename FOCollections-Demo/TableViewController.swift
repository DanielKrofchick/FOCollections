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
        queueUpdate({[weak self] in self?.clearAllItems()})

//        queueUpdate({[weak self] in self?.insertSections([self!.section(items: 0)], indexes: NSIndexSet(index: 0))})
//        queueUpdate({[weak self] in self?.insertItems([self!.item(UIColor.redColor())], indexPaths: [NSIndexPath(forItem: 0, inSection: 0)])})
//        queueUpdate({[weak self] in self?.insertItems([self!.item(UIColor.orangeColor())], indexPaths: [NSIndexPath(forItem: 0, inSection: 0)])})
//        queueUpdate({[weak self] in self?.insertItems([self!.item(UIColor.yellowColor())], indexPaths: [NSIndexPath(forItem: 0, inSection: 0)])})
//        queueUpdate({[weak self] in self?.insertItems([self!.item(UIColor.greenColor())], indexPaths: [NSIndexPath(forItem: 0, inSection: 0)])})
//        queueUpdate({[weak self] in self?.insertItems([self!.item(UIColor.blueColor())], indexPaths: [NSIndexPath(forItem: 0, inSection: 0)])})
//        queueUpdate({[weak self] in self?.insertItems([self!.item(UIColor.purpleColor())], indexPaths: [NSIndexPath(forItem: 0, inSection: 0)])})
//        queueUpdate({[weak self] in self?.insertItems([self!.item(UIColor.brownColor())], indexPaths: [NSIndexPath(forItem: 0, inSection: 0)])})
//        queueUpdate({[weak self] in self?.insertItems([self!.item(UIColor.blackColor())], indexPaths: [NSIndexPath(forItem: 0, inSection: 0)])})
//        
//        queueUpdate({[weak self] in
//            for (index, item) in self!.dataSource.enumerate() {
//                print("index: \(index) color: \(item.data)")
//            }
//        })
        
        queueUpdate({[weak self] in self?.insertSections([self!.section()], indexes: IndexSet(integer: 0))})
//        queueUpdate({[weak self] in self?.deleteSectionsAtIndexes(NSIndexSet(index: 0))})
//        queueUpdate({[weak self] in self?.insertSections([self!.section(UIColor.brownColor())], indexes: NSIndexSet(index: 0))})
//        queueUpdate({[weak self] in self?.insertItems([self!.item(UIColor.yellowColor())], indexPaths: [NSIndexPath(forItem: 0, inSection: 0)])})
//        queueUpdate({[weak self] in self?.deleteItemsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)])})
        queueUpdate({[weak self] in self?.appendItems(self!.items(UIColor.red, items: 3), toSectionAtIndex: 0)})
        queueUpdate({[weak self] in self?.prependItems(self!.items(UIColor.purple, items: 3), toSectionAtIndex: 0)})
        queueUpdate({[weak self] in self?.setPagingState(.paging, sectionIndex: 0)})
        queueUpdate({[weak self] in self?.setPagingState(.disabled, sectionIndex: 0)})
        queueUpdate({[weak self] in self?.setPagingState(.paging, sectionIndex: 0)})
        queueUpdate({[weak self] in self?.setPagingState(.finished, sectionIndex: 0)})
        queueUpdate({[weak self] in self?.setPagingState(.notPaging, sectionIndex: 0)})
    }
    
    func section(_ color: UIColor = UIColor.blue, items: Int = 4) -> FOTableSection {
        let section = FOTableSection()
        
        section.identifier = UUID().uuidString
        section.pagingState = .notPaging
        section.items = self.items(color, items: items)
        section.pagingDirection = .down
        
        return section
    }
    
    func items(_ color: UIColor = UIColor.blue, items: Int = 1) -> [FOTableItem] {
        var r = [FOTableItem]()
        
        if items > 0 {
            for _ in 0...items - 1 {
                r.append(item(color))
            }
        }
        
        return r
    }
    
    func item(_ color: UIColor = UIColor.blue) -> FOTableItem {
        let item = TableCellItem()
        
        item.data = color
        item.identifier = UUID().uuidString
        item.reuseIdentifier = "itemReuseIdentifier"
        item.cellClass = UITableViewCell.self
        
        return item
    }
    
    override func nextPageForSection(_ section: FOTableSection, tableView: UITableView) {
        print("\(#function)")
    }
    
}

