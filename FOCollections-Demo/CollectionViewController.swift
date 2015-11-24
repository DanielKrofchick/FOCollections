//
//  ViewController.swift
//  FOCollections-FrameworkTest
//
//  Created by Daniel Krofchick on 2015-11-12.
//  Copyright © 2015 Figure1. All rights reserved.
//

import UIKit

class CollectionViewController: FOCollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.orangeColor()
        
//        loadSections(sections(), completion: {(finished) -> () in print("done1")})
//        insertSections(sections(), indexes: NSIndexSet(index: 0), completion: {(finished) -> () in print("done2")})
//        insertItems([item()], indexPaths: [NSIndexPath(forItem: 0, inSection: 0)], completion: {(finished) -> () in print("done3")})
        loadSections(sections(), completion: {(finished) -> () in print("done4")})
        appendItems([item(), item(), item()], toSectionAtIndex: 0, completion: {(finished) -> () in print("done5")})
    }
    
    func sections() -> [FOCollectionSection] {
        let section = self.section()
        
        section.items = [
            item(),
            item(),
            item(),
            item(),
            item(),
            item(),
            item(),
        ]
        
        return [section]
    }
    
    func section() -> FOCollectionSection {
        let section = FOCollectionSectionItem()
        
        section.identifier = NSUUID().UUIDString
        section.pagingState = .NotPaging
        section.columns = 8
        
        return section
    }
    
    func item() -> FOCollectionItem {
        let item = FOCollectionCellItem()
        
        item.data = UIColor.greenColor()
        item.identifier = NSUUID().UUIDString
        item.reuseIdentifier = "itemReuseIdentifier"
        item.cellClass = UICollectionViewCell.self
        item.columns = 1 //Int(arc4random_uniform(2) + 1)
        
        return item
    }

}
