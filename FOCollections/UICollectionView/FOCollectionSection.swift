//
//  FOCollectionSection.swift
//  Figure1
//
//  Created by Daniel Krofchick on 2015-04-18.
//  Copyright (c) 2015 Movable Science. All rights reserved.
//

import UIKit

open class FOCollectionSection: NSObject, UICollectionViewDelegateFlowLayout {

    open var items: [FOCollectionItem]? = nil
    open var identifier: String? = nil                                           // Unique item ID
    open var pagingState: PagingState = .disabled
    open var pagingDirection: PagingDirection = .down
    open var columns: Int? = nil
    
    open func linkItems(_ viewController: UIViewController?) {
        items?.forEach{
            $0.link(self, viewController: viewController)
        }
    }
    
    open func itemAtIndex(_ index: Int) -> FOCollectionItem? {
        return items?.safe(index)
    }
    
    func indexPathsForItem(_ item: FOCollectionItem, section: Int) -> [IndexPath] {
        var indexPaths = [IndexPath]()
        
        if let items = items {
            for (itemIndex, i) in items.enumerated() {
                if item.isEqual(i) {
                    indexPaths.append(IndexPath(item: itemIndex, section: section))
                }
            }
        }
        
        return indexPaths
    }
    
    func indexPathsForData(_ data: AnyObject, section: Int) -> [IndexPath] {
        var indexPaths = [IndexPath]()
        
        if let items = items {
            for (itemIndex, item) in items.enumerated() {
                if item.data != nil {
                    if item.data!.isEqual(data) {
                        indexPaths.append(IndexPath(item: itemIndex, section: section))
                    }
                }
            }
        }
        
        return indexPaths
    }
    
    open func pageFetchComplete() {
        pagingState = .paging
    }
    
}
