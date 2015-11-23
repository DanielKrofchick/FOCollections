//
//  FOTableConfigurator.swift
//  FOCollectionsExamples
//
//  Created by Daniel Krofchick on 2015-11-11.
//  Copyright © 2015 Figure1. All rights reserved.
//

import UIKit

public class FOTableConfigurator: NSObject {
    
    weak public var item: FOTableItem? = nil
    weak public var viewController: UIViewController? = nil
    
    public func configure(cell: UITableViewCell, tableView: UITableView, indexPath: NSIndexPath){}
    public func getExtras(tableView: UITableView, indexPath: NSIndexPath){}
    public func setExtras(tableView: UITableView, indexPath: NSIndexPath, extras: [NSObject: AnyObject]){}
}