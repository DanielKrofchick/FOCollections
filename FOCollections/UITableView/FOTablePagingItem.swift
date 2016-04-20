//
//  FOTablePagingItem.swift
//  FOCollections
//
//  Created by Daniel Krofchick on 2015-11-23.
//  Copyright © 2015 Figure1. All rights reserved.
//

import UIKit

public let tablePagingItemReuseIdentifier = "pagingItemResuseIdentifier"

class FOTablePagingItem: FOTableItem {
    
    init(section: FOTableSection) {
        super.init()
        
        identifier = "pagingItem-\(section.identifier)"
        reuseIdentifier = tablePagingItemReuseIdentifier
        cellClass = UITableViewCell.self
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(44)
    }
    
    override func configure(cell: UITableViewCell, tableView: UITableView, indexPath: NSIndexPath) {
        cell.contentView.backgroundColor = UIColor.greenColor()
        cell.selectionStyle = .None
    }
    
}
