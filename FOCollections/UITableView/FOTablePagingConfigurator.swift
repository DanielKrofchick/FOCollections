//
//  FOTablePagingConfigurator.swift
//  FOCollectionsExamples
//
//  Created by Daniel Krofchick on 2015-11-12.
//  Copyright © 2015 Figure1. All rights reserved.
//

import UIKit

public class FOTablePagingConfigurator: FOTableConfigurator {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(44)
    }
    
    public override func configure(cell: UITableViewCell, tableView: UITableView, indexPath: NSIndexPath) {
        cell.contentView.backgroundColor = UIColor.greenColor()
        cell.selectionStyle = .None
    }
    
}
