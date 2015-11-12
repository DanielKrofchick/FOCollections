//
//  FOTableConfiguratorFactory.swift
//  FOCollectionsExamples
//
//  Created by Daniel Krofchick on 2015-11-12.
//  Copyright © 2015 Figure1. All rights reserved.
//

import Foundation
import UIKit
import FOCollections

class FOTableItemConfigurator: FOTableConfigurator {

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    override func configure(cell: UITableViewCell, tableView: UITableView, indexPath: NSIndexPath) {
        cell.contentView.backgroundColor = UIColor.blueColor()
    }
    
}

class FOTableSectionConfigurator: FOTableConfigurator {
    
    var edgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    var minimumLineSpacing = CGFloat(5)
    var minimumInteritemSpacing = CGFloat(5)
    
    override init() {
        super.init()
        
        item = FOTableItem()
    }
    
}