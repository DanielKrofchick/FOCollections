//
//  FOTableSection.swift
//  FOCollectionsExamples
//
//  Created by Daniel Krofchick on 2015-11-11.
//  Copyright © 2015 Figure1. All rights reserved.
//

import UIKit

public class FOTableSection: NSObject {
    
    public var items: [FOTableItem]? = nil
    public var identifier: String? = nil                                           // Unique item ID
    public var pagingState: PagingState = .Disabled
    public var configurator: FOTableConfigurator? = nil
    
    func linkItems(viewController: UIViewController?) {
        items?.forEach{
            $0.link(self, viewController: viewController)
        }
    }
    
    func itemAtIndex(index: Int) -> FOTableItem? {
        return items?.safe(index)
    }
    
    func indexPathsForItem(item: FOTableItem, section: Int) -> [NSIndexPath] {
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