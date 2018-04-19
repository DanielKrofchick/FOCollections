//
//  MenuItem.swift
//  FOCollections
//
//  Created by Daniel Krofchick on 2016-02-17.
//  Copyright © 2016 Figure 1 Inc. All rights reserved.
//

import UIKit

class MenuItem: FOTableItem {
    
    override func configure(_ cell: UITableViewCell, tableView: UITableView, indexPath: IndexPath) {
        //[title, color]
        if let data = data as? [String: Any] {
            if let color = data["color"] as? UIColor {
                cell.backgroundColor = color
            }
            if let text = data["text"] as? String {
                cell.textLabel?.text = text
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        if identifier == tableIdentifier {
            viewController?.navigationController?.pushViewController(TableViewController(), animated: true)
        } else if identifier == collectionIdentifier {
            viewController?.navigationController?.pushViewController(CollectionViewController(), animated: true)
        }
    }
    
}
