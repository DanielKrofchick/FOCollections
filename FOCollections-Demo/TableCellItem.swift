//
//  TableCellItem.swift
//  FOCollections
//
//  Created by Daniel Krofchick on 2015-11-23.
//  Copyright © 2015 Figure1. All rights reserved.
//

import UIKit

class TableCellItem: FOTableItem {
    
    override func configure(_ cell: UITableViewCell, tableView: UITableView, indexPath: IndexPath) {
        if let color = data as? UIColor {
            cell.contentView.backgroundColor = color
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return 50.0
    }

}
