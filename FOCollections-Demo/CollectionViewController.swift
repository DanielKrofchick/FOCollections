//
//  ViewController.swift
//  FOCollections-FrameworkTest
//
//  Created by Daniel Krofchick on 2015-11-12.
//  Copyright © 2015 Figure1. All rights reserved.
//

import UIKit

class CollectionViewController: FOCollectionViewController {
    
    let refresh = UIButton(type: .System)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.orangeColor()
        
        refresh.addTarget(self, action: "refreshTap", forControlEvents: .TouchUpInside)
        refresh.backgroundColor = UIColor.yellowColor()
        view.addSubview(refresh)
        
        play()
    }
    
    func refreshTap() {
        play()
    }
    
    func play() {
        queueUpdate({[weak self] in self?.clearAllItems()})
        
        queueUpdate({[weak self] in self?.insertSections([self!.section(UIColor.blueColor())], indexes: NSIndexSet(index: 0))})
        queueUpdate({[weak self] in self?.deleteSectionsAtIndexes(NSIndexSet(index: 0))})
        queueUpdate({[weak self] in self?.insertSections([self!.section(UIColor.blueColor())], indexes: NSIndexSet(index: 0))})
        queueUpdate({[weak self] in self?.insertItems([self!.item(UIColor.yellowColor())], indexPaths: [NSIndexPath(forItem: 0, inSection: 0)])})
        queueUpdate({[weak self] in self?.deleteItemsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)])})
        queueUpdate({[weak self] in self?.appendItems(self!.items(UIColor.purpleColor(), items: 3), toSectionAtIndex: 0)})
        queueUpdate({[weak self] in self?.setPagingState(.Paging, sectionIndex: 0)})
        queueUpdate({[weak self] in self?.setPagingState(.Disabled, sectionIndex: 0)})
        queueUpdate({[weak self] in self?.setPagingState(.Paging, sectionIndex: 0)})
        queueUpdate({[weak self] in self?.setPagingState(.Finished, sectionIndex: 0)})
        queueUpdate({[weak self] in self?.setPagingState(.NotPaging, sectionIndex: 0)})
        queueUpdate({[weak self] in self?.clearAllItems()})
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let s = CGSize(width: 50, height: 50)
        let BI = CGFloat(20)
    
        refresh.frame = CGRect(x: (view.frame.width - s.width) / 2.0, y: view.frame.height - s.height - BI, width: s.width, height: s.height)
    }
    
    func section(color: UIColor = UIColor.blueColor(), items: Int = 8) -> FOCollectionSection {
        let section = FOCollectionSectionItem()
        
        section.identifier = NSUUID().UUIDString
        section.pagingState = .Disabled
        section.columns = 8
        section.items = self.items(color, items: items)
        
        return section
    }
    
    func items(color: UIColor = UIColor.blueColor(), items: Int = 1) -> [FOCollectionItem] {
        var r = [FOCollectionItem]()
        
        for _ in 0...items - 1 {
            r.append(item(color))
        }
        
        return r
    }
    
    func item(color: UIColor = UIColor.blueColor()) -> FOCollectionItem {
        let item = FOCollectionCellItem()
        
        item.data = color
        item.identifier = NSUUID().UUIDString
        item.reuseIdentifier = "itemReuseIdentifier"
        item.cellClass = UICollectionViewCell.self
        item.columns = 1 //Int(arc4random_uniform(3) + 1)
        
        return item
    }

}
