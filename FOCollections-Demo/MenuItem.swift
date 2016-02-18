//
//  MenuItem.swift
//  FOCollections
//
//  Created by Daniel Krofchick on 2016-02-17.
//  Copyright © 2016 Figure1. All rights reserved.
//

import UIKit

class MenuItem: FOTableItem {
    
    override func configure(cell: UITableViewCell, tableView: UITableView, indexPath: NSIndexPath) {
        //[title, color]
        if let data = data as? [AnyObject] {
            if let color = data.first as? UIColor {
                cell.backgroundColor = color
            }
            if let text = data.safe(1) as? String {
                cell.textLabel?.text = text
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if identifier == tableIdentifier {
            viewController?.navigationController?.pushViewController(TableViewController(), animated: true)
        } else if identifier == collectionIdentifier {
            viewController?.navigationController?.pushViewController(CollectionViewController(), animated: true)
        }
    }
    
}
