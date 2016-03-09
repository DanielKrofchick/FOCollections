//
//  FOCollectionItem.swift
//  Figure1
//
//  Created by Daniel Krofchick on 2015-04-18.
//  Copyright (c) 2015 Movable Science. All rights reserved.
//

import UIKit

public class FOCollectionItem: NSObject, UICollectionViewDelegateFlowLayout {

    public var data: AnyObject? = nil                                              // Data cargo
    public var identifier: String? = nil                                           // Unique item ID
    public var reuseIdentifier: String? = nil                                      // collectionView reuseIdentifier
    public var cellClass: AnyClass? = nil                                          // View Class to register with the collectionView
    public var columns = Int(1)                                                    // Columns spanned by the item, depends on layout
    public weak var section: FOCollectionSection?                                  // Weak reference to section
    public weak var viewController: UIViewController? = nil                        // Weak reference to viewController
    
    public func configure(cell: UICollectionViewCell, collectionView: UICollectionView, indexPath: NSIndexPath){}
    // Gets the reource identified by key
    public func getResource(forKey key: String, collectionView: UICollectionView, indexPath: NSIndexPath, completion: (resource: AnyObject?, result: AnyObject?) -> ()) -> NSOperation? {return nil}
    // Populates the cell with the resource identified by key. IndexPath may have changed with async call, do not rely on it.
    public func setResource(resource: AnyObject?, result: AnyObject?, forKey key: String, collectionView: UICollectionView, indexPath: NSIndexPath){}
    // The item produces a unique key per resource
    public func resourceKeys() -> [String]{return [String]()}
    
    public func getResources(collectionView: UICollectionView, indexPath: NSIndexPath) -> [NSOperation] {
        var operations = [NSOperation]()
        
        for key in resourceKeys() {
            if let operation = getResource(forKey: key, collectionView: collectionView, indexPath: indexPath, completion: {[weak self] (resource, result) -> () in
                self?.setResource(resource, result: result, forKey: key, collectionView: collectionView, indexPath: indexPath)
            }) {
                operations.append(operation)
            }
        }
        
        return operations
    }
    
    public func cells() -> [UICollectionViewCell] {
        var cells = [UICollectionViewCell]()
        
        if let viewController = viewController as? FOCollectionViewController {
            for indexPath in viewController.dataSource.indexPathsForItem(self) {
                if let cell = viewController.collectionView?.cellForItemAtIndexPath(indexPath) {
                    cells.append(cell)
                }
            }
        }
        
        return cells
    }

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
    
    func link(section: FOCollectionSection?, viewController: UIViewController?) {
        self.section = section
        self.viewController = viewController
    }
    
    public func widthForCollectionView(collectionView: UICollectionView, indexPath: NSIndexPath) -> CGFloat? {
        if let collectionViewLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout, viewController = viewController as? UICollectionViewDelegateFlowLayout  {
            if let sectionInsets = viewController.collectionView?(collectionView, layout: collectionViewLayout, insetForSectionAtIndex: indexPath.section),
                minimumInterItemSpacing = viewController.collectionView?(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAtIndex: indexPath.section),
                sectionColumns = section?.columns {
                    let itemColumns = CGFloat(columns ?? 1)
                    let columnWidth = (collectionView.frame.size.width - sectionInsets.left - sectionInsets.right - (CGFloat(sectionColumns) - CGFloat(1.0)) * minimumInterItemSpacing) / CGFloat(sectionColumns)
                    
                    return columnWidth * itemColumns + minimumInterItemSpacing * (itemColumns - 1)
            }
        }
        
        return nil
    }
    
}
