//
//  TableCellItem.swift
//  FOCollections
//
//  Created by Daniel Krofchick on 2015-11-23.
//  Copyright © 2015 Figure1. All rights reserved.
//

import UIKit

class TableCellItem: FOTableItem {
    
    override func configure(cell: UITableViewCell, tableView: UITableView, indexPath: NSIndexPath) {
        if let color = data as? UIColor {
            cell.contentView.backgroundColor = color
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }

}