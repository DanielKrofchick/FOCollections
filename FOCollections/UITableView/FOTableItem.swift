//
//  FOTableItem.swift
//  FOCollectionsExamples
//
//  Created by Daniel Krofchick on 2015-11-11.
//  Copyright © 2015 Figure1. All rights reserved.
//

import UIKit

open class FOTableItem: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    open var data: Any? = nil                                              // Data cargo
    open var identifier: String? = nil                                           // Unique item ID
    open var reuseIdentifier: String? = nil                                      // collectionView reuseIdentifier
    open var cellClass: AnyClass? = nil                                          // View Class to register with the collectionViews
    open var operations = [Operation]()                                        // Operations returned from getResources are stored here and cancelled on cell didEndDisplaying
    weak open var section: FOTableSection?                                       // Weak reference to section
    weak open var viewController: UIViewController? = nil
    
    open func configure(_ cell: UITableViewCell, tableView: UITableView, indexPath: IndexPath){}
    // Gets the reource identified by key
    open func getResource(forKey key: String, tableView: UITableView, indexPath: IndexPath, completion: @escaping (_ resource: AnyObject?, _ result: AnyObject?) -> ()) -> Operation? {return nil}
    // Populates the cell with the resource identified by key. IndexPath may have changed with async call, do not rely on it.
    open func setResource(_ resource: AnyObject?, result: AnyObject?, forKey key: String, tableView: UITableView, indexPath: IndexPath){}
    // The item produces a unique key per resource
    open func resourceKeys() -> [String]{return [String]()}
    
    open func getResources(_ tableView: UITableView, indexPath: IndexPath) -> [Operation] {
        var operations = [Operation]()
        
        for key in resourceKeys() {
            if let operation = getResource(forKey: key, tableView: tableView, indexPath: indexPath, completion: {[weak self] (resource, result) -> () in
                self?.setResource(resource, result: result, forKey: key, tableView: tableView, indexPath: indexPath)
            }) {
                operations.append(operation)
            }
        }
        
        return operations
    }
    
    open func cells() -> [UITableViewCell] {
        var cells = [UITableViewCell]()

        if let viewController = viewController as? FOTableViewController {
            for indexPath in viewController.dataSource.indexPathsForItem(self) {
                if let cell = viewController.tableView.cellForRow(at: indexPath) {
                    cells.append(cell)
                }
            }
        }
        
        return cells
    }

    open func indexPaths() -> [IndexPath] {
        var indexPaths = [IndexPath]()
        
        if let viewController = viewController as? FOTableViewController {
            indexPaths = viewController.dataSource.indexPathsForItem(self)
        }
        
        return indexPaths
    }
    
    open override func isEqual(_ o: Any?) -> Bool {
        if let o = o as? FOTableItem {
            if o.data == nil && data == nil {
                return o.identifier == identifier
            } else if o.data != nil && data != nil {
                return (o.identifier == identifier) && (o.data! as AnyObject).isEqual(data!)
            } else {
                return false
            }
        } else {
            return false
        }

    }
    
    func link(_ section: FOTableSection?, viewController: UIViewController?) {
        self.section = section
        self.viewController = viewController
    }
    
    // Dummy protocol definitions. These are not implemented by FOTableItem
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {return 0}
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {return UITableViewCell()}
    
}
