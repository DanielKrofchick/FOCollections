//
//  FOTableSection.swift
//  FOCollectionsExamples
//
//  Created by Daniel Krofchick on 2015-11-11.
//  Copyright © 2015 Figure1. All rights reserved.
//

import UIKit

public class FOTableSection: NSObject, UITableViewDelegate {
    
    public var items: [FOTableItem]? = nil
    public var identifier: String? = nil                                           // Unique item ID
    public var pagingState: PagingState = .Disabled
    public var pagingDirection: PagingDirection = .Down
    public var header: UIView? = nil
    public var footer: UIView? = nil
    
    public func linkItems(viewController: UIViewController?) {
        items?.forEach{
            $0.link(self, viewController: viewController)
        }
    }
    
    public func itemAtIndex(index: Int) -> FOTableItem? {
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
    
    public func pageFetchComplete() {
        pagingState = .Paging
    }
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        sizeView(header, tableView: tableView)
        
        return header
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        sizeView(header, tableView: tableView)
        
        return header?.frame.height ?? 0
    }
    
    public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        sizeView(footer, tableView: tableView)
        
        return footer
    }
    
    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        sizeView(footer, tableView: tableView)
        
        return footer?.frame.height ?? 0
    }
    
    private func sizeView(view: UIView?, tableView: UITableView) {
        if let view = view {
            let size = view.sizeThatFits(CGSize(width: tableView.frame.width, height: CGFloat.max))
            view.frame = CGRect(origin: view.frame.origin, size: CGSize(width: tableView.frame.width, height: size.height))
        }
    }
    
}