//
//  FOTableItem.swift
//  FOCollectionsExamples
//
//  Created by Daniel Krofchick on 2015-11-11.
//  Copyright © 2015 Figure1. All rights reserved.
//

import UIKit

public class FOTableItem: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    public var data: AnyObject? = nil                                              // Data cargo
    public var identifier: String? = nil                                           // Unique item ID
    public var reuseIdentifier: String? = nil                                      // collectionView reuseIdentifier
    public var cellClass: AnyClass? = nil                                          // View Class to register with the collectionView
    weak public var section: FOTableSection?                                       // Weak reference to section
    weak public var viewController: UIViewController? = nil
    
    public func configure(cell: UITableViewCell, tableView: UITableView, indexPath: NSIndexPath){}
    public func getExtras(tableView: UITableView, indexPath: NSIndexPath){}
    public func setExtras(tableView: UITableView, indexPath: NSIndexPath, extras: [NSObject: AnyObject]){}
    
    override public func isEqual(o: AnyObject?) -> Bool {
        if let o = o as? FOCollectionItem {
            if o.data == nil && data == nil {
                return o.identifier == identifier
            } else if o.data != nil && data != nil {
                return (o.identifier == identifier) && o.data!.isEqual(data!)
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func link(section: FOTableSection?, viewController: UIViewController?) {
        self.section = section
        self.viewController = viewController
    }
    
    // Dummy protocol definitions. These are not implemented by FOTableItem
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {return 0}
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {return UITableViewCell()}
    
}
