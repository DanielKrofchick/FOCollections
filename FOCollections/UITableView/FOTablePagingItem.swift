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
        
        identifier = "pagingItem-\(String(describing: section.identifier))"
        reuseIdentifier = tablePagingItemReuseIdentifier
        cellClass = UITableViewCell.self
    }

    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return CGFloat(44)
    }
    
    override func configure(_ cell: UITableViewCell, tableView: UITableView, indexPath: IndexPath) {
        cell.contentView.backgroundColor = UIColor.green
        cell.selectionStyle = .none
    }
    
}
