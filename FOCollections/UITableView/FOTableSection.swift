//
//  FOTableSection.swift
//  FOCollectionsExamples
//
//  Created by Daniel Krofchick on 2015-11-11.
//  Copyright © 2015 Figure1. All rights reserved.
//

import UIKit

open class FOTableSection: NSObject, UITableViewDelegate {
    
    open var items: [FOTableItem]? = nil
    open var identifier: String? = nil                  // Unique item ID
    open var pagingState: PagingState = .disabled
    open var pagingDirection: PagingDirection = .down
    open var header: UIView? = nil                      // Fixed header
    open var footer: UIView? = nil                      // Fixed footer
    
    open func linkItems(_ viewController: UIViewController?) {
        items?.forEach{
            $0.link(self, viewController: viewController)
        }
    }
    
    open func itemAtIndex(_ index: Int) -> FOTableItem? {
        return items?.safe(index)
    }
    
    func indexPathsForItem(_ item: FOTableItem, section: Int) -> [IndexPath] {
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
                    if (item.data! as AnyObject).isEqual(data) {
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
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return header
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let view = self.tableView(tableView, viewForHeaderInSection: section)
        
        sizeView(view, tableView: tableView)
        
        return view?.frame.height ?? 0
    }
    
    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footer
    }
    
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let view = self.tableView(tableView, viewForFooterInSection: section)
        
        sizeView(view, tableView: tableView)
        
        return view?.frame.height ?? 0
    }
    
    fileprivate func sizeView(_ view: UIView?, tableView: UITableView) {
        if let view = view {
            let size = view.sizeThatFits(CGSize(width: tableView.frame.width, height: CGFloat.greatestFiniteMagnitude))
            view.frame = CGRect(origin: view.frame.origin, size: CGSize(width: tableView.frame.width, height: size.height))
        }
    }
    
    open override func isEqual(_ object: Any?) -> Bool {
        return identifier == (object as? FOTableSection)?.identifier
    }
    
}
