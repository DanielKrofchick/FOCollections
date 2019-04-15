//
//  ViewController.swift
//  FOCollections-FrameworkTest
//
//  Created by Daniel Krofchick on 2015-11-12.
//  Copyright © 2015 Figure 1 Inc. All rights reserved.
//

import UIKit

class CollectionViewController: FOCollectionViewController {
    
    convenience init() {
        self.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.orange
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(CollectionViewController.play))
        
        play()
    }
    
    @objc func play() {
        queueUpdate({[weak self] in self?.clearAllItems()})
        
        queueUpdate({[weak self] in self?.insertSections([self!.section(UIColor.blue)], indexes: IndexSet(integer: 0))})
        queueUpdate({[weak self] in self?.deleteSectionsAtIndexes(IndexSet(integer: 0))})
        queueUpdate({[weak self] in self?.insertSections([self!.section(UIColor.brown)], indexes: IndexSet(integer: 0))})
        queueUpdate({[weak self] in self?.insertItems([self!.item(UIColor.yellow)], indexPaths: [IndexPath(item: 0, section: 0)])})
        queueUpdate({[weak self] in self?.deleteItemsAtIndexPaths([IndexPath(item: 0, section: 0)])})
        queueUpdate({[weak self] in self?.appendItems(self!.items(UIColor.purple, items: 3), toSectionAtIndex: 0)})
        queueUpdate({[weak self] in self?.setPagingState(.paging, sectionIndex: 0)})
        queueUpdate({[weak self] in self?.setPagingState(.disabled, sectionIndex: 0)})
        queueUpdate({[weak self] in self?.setPagingState(.paging, sectionIndex: 0)})
        queueUpdate({[weak self] in self?.setPagingState(.finished, sectionIndex: 0)})
        queueUpdate({[weak self] in self?.setPagingState(.notPaging, sectionIndex: 0)})
        queueUpdate({[weak self] in self?.setPagingState(.paging, sectionIndex: 0)})
        queueUpdate({[weak self] in self?.prependItems(self!.items(UIColor.green, items: 3), toSectionAtIndex: 0)})
    }
    
    func section(_ color: UIColor = UIColor.blue, items: Int = 8) -> FOCollectionSection {
        let section = CollectionSectionItem()
        
        section.identifier = UUID().uuidString
        section.pagingState = .notPaging
        section.columns = 8
        section.items = self.items(color, items: items)
        section.pagingDirection = .down
        
        return section
    }
    
    func items(_ color: UIColor = UIColor.blue, items: Int = 1) -> [FOCollectionItem] {
        var r = [FOCollectionItem]()
        
        for _ in 0...items - 1 {
            r.append(item(color))
        }
        
        return r
    }
    
    func item(_ color: UIColor = UIColor.blue) -> FOCollectionItem {
        let item = CollectionCellItem()
        
        item.data = color
        item.identifier = UUID().uuidString
        item.reuseIdentifier = "itemReuseIdentifier"
        item.cellClass = UICollectionViewCell.self
        item.columns = 1 //Int(arc4random_uniform(3) + 1)
        
        return item
    }
    
    override func nextPageForSection(_ section: FOCollectionSection, collectionView: UICollectionView) {
        print("\(#function)")
    }

}
