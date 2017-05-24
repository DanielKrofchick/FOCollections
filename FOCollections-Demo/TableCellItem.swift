//
//  TableCellItem.swift
//  FOCollections
//
//  Created by Daniel Krofchick on 2015-11-23.
//  Copyright © 2015 Figure1. All rights reserved.
//

import UIKit

class TableCellItem: FOTableItem {
    
    var color = UIColor.white
    
    required init(identifier: String, color: UIColor = .white) {
        super.init()
        
        self.identifier = identifier
        self.color = color
        reuseIdentifier = NSStringFromClass(type(of: self))
        cellClass = UITableViewCell.self
    }
    
    override func configure(_ cell: UITableViewCell, tableView: UITableView, indexPath: IndexPath) {
        cell.backgroundColor = color
        cell.textLabel?.text = identifier
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return 50.0
    }

}
