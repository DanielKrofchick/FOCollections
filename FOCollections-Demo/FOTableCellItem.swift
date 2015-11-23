//
//  FOTableCellItem.swift
//  FOCollections
//
//  Created by Daniel Krofchick on 2015-11-23.
//  Copyright © 2015 Figure1. All rights reserved.
//

import UIKit

class FOTableCellItem: FOTableItem {
    
    override func configure(cell: UITableViewCell, tableView: UITableView, indexPath: NSIndexPath) {
        cell.contentView.backgroundColor = UIColor.blueColor()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }

}