//
//  TableCellItem.swift
//  FOCollections
//
//  Created by Daniel Krofchick on 2015-11-23.
//  Copyright © 2015 Figure1. All rights reserved.
//

import UIKit

class DemoTableItem: FOTableItem {
    
    var color = UIColor.white
    
    required init(identifier: String, color: UIColor = .white) {
        super.init()
        
        self.identifier = identifier
        self.color = color
        reuseIdentifier = NSStringFromClass(type(of: self))
        cellClass = DemoTableCell.self
    }
    
    override func configure(_ cell: UITableViewCell, tableView: UITableView, indexPath: IndexPath) {
        cell.textLabel?.text = identifier
        
        if let section = section as? DemoTableSection {
            cell.backgroundColor = section.color
        }
        
        if let cell = cell as? DemoTableCell {
            cell.indicator.backgroundColor = color
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return 25
    }
    
    override func copy() -> Any {
        let item = DemoTableItem(identifier: identifier!)
        item.color = color
        
        return item
    }

}
