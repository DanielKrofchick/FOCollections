//
//  FOCollectionSection.swift
//  Figure1
//
//  Created by Daniel Krofchick on 2015-04-18.
//  Copyright (c) 2015 Movable Science. All rights reserved.
//

import UIKit

public class FOCollectionSection: NSObject, UICollectionViewDelegateFlowLayout {

    public var items: [FOCollectionItem]? = nil
    public var identifier: String? = nil                                           // Unique item ID
    public var pagingState: PagingState = .Disabled
    public var pagingDirection: PagingDirection = .Down
    public var columns: Int? = nil
    
    func linkItems(viewController: UIViewController?) {
        items?.forEach{
            $0.link(self, viewController: viewController)
        }
    }
    
    func itemAtIndex(index: Int) -> FOCollectionItem? {
        return items?.safe(index)
    }
    
    func indexPathsForItem(item: FOCollectionItem, section: Int) -> [NSIndexPath] {
        var indexPaths = [NSIndexPath]()
        
        if let items = items {
            for (itemIndex, i) in items.enumerate() {
                if item.isEqual(i) {
                    indexPaths.append(NSIndexPath(forItem: itemIndex, inSection: section))
                }
            }
        }
        
        return indexPaths
    }
    
    func indexPathsForData(data: AnyObject, section: Int) -> [NSIndexPath] {
        var indexPaths = [NSIndexPath]()
        
        if let items = items {
            for (itemIndex, item) in items.enumerate() {
                if item.data != nil {
                    if item.data!.isEqual(data) {
                        indexPaths.append(NSIndexPath(forItem: itemIndex, inSection: section))
                    }
                }
            }
        }
        
        return indexPaths
    }
    
}
