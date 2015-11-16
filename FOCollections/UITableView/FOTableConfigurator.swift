//
//  FOTableConfigurator.swift
//  FOCollectionsExamples
//
//  Created by Daniel Krofchick on 2015-11-11.
//  Copyright © 2015 Figure1. All rights reserved.
//

import UIKit

public class FOTableConfigurator: NSObject, FOTableConfiguratorProtocol {
    
    weak public var item: FOTableItem? = nil
    weak public var viewController: UIViewController? = nil
    
    public func configure(cell: UITableViewCell, tableView: UITableView, indexPath: NSIndexPath){}
    public func getExtras(tableView: UITableView, indexPath: NSIndexPath){}
    public func setExtras(tableView: UITableView, indexPath: NSIndexPath, extras: [NSObject: AnyObject]){}
    
    // Dummy protocol definitions. These are not implemented by configurator
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {return 0}
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {return UITableViewCell()}
    
}

public protocol FOTableConfiguratorProtocol: UITableViewDelegate, UITableViewDataSource {
    
    weak var item: FOTableItem? {get set}
    weak var viewController: UIViewController? {get set}
    
    func configure(cell: UITableViewCell, tableView: UITableView, indexPath: NSIndexPath)
    func getExtras(tableView: UITableView, indexPath: NSIndexPath)
    func setExtras(tableView: UITableView, indexPath: NSIndexPath, extras: [NSObject: AnyObject])
    
}
