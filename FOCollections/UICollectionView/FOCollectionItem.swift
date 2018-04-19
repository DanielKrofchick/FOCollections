//
//  FOCollectionItem.swift
//  Figure1
//
//  Created by Daniel Krofchick on 2015-04-18.
//  Copyright (c) 2015 Movable Science. All rights reserved.
//

import UIKit

open class FOCollectionItem: NSObject, UICollectionViewDelegateFlowLayout {

    open var data: AnyObject? = nil                                              // Data cargo
    open var identifier: String? = nil                                           // Unique item ID
    open var reuseIdentifier: String? = nil                                      // collectionView reuseIdentifier
    open var cellClass: AnyClass? = nil                                          // View Class to register with the collectionView
    open var columns = Int(1)                                                    // Columns spanned by the item, depends on layout
    open var operations = [Operation]()                                        // Operations returned from getResources are stored here and cancelled on cell didEndDisplaying
    open weak var section: FOCollectionSection?                                  // Weak reference to section
    open weak var viewController: UIViewController? = nil                        // Weak reference to viewController
    
    open func configure(_ cell: UICollectionViewCell, collectionView: UICollectionView, indexPath: IndexPath){}
    // Gets the reource identified by key
    open func getResource(forKey key: String, collectionView: UICollectionView, indexPath: IndexPath, completion: @escaping (_ resource: AnyObject?, _ result: AnyObject?) -> ()) -> Operation? {return nil}
    // Populates the cell with the resource identified by key. IndexPath may have changed with async call, do not rely on it.
    open func setResource(_ resource: AnyObject?, result: AnyObject?, forKey key: String, collectionView: UICollectionView, indexPath: IndexPath){}
    // The item produces a unique key per resource
    open func resourceKeys() -> [String]{return [String]()}
    
    open func getResources(_ collectionView: UICollectionView, indexPath: IndexPath) -> [Operation] {
        var operations = [Operation]()
        
        for key in resourceKeys() {
            if let operation = getResource(forKey: key, collectionView: collectionView, indexPath: indexPath, completion: {[weak self] (resource, result) -> () in
                self?.setResource(resource, result: result, forKey: key, collectionView: collectionView, indexPath: indexPath)
            }) {
                operations.append(operation)
            }
        }
        
        return operations
    }
    
    open func cell() -> UICollectionViewCell? {
        if
            let viewController = viewController as? FOCollectionViewController,
            let indexPath = viewController.dataSource.indexPathForItem(self),
            let cell = viewController.collectionView?.cellForItem(at: indexPath)
        {
            return cell
        }
        
        return nil
    }
    
    open func cells() -> [UICollectionViewCell] {
        var cells = [UICollectionViewCell]()
        
        if let viewController = viewController as? FOCollectionViewController {
            for indexPath in viewController.dataSource.indexPathsForItem(self) {
                if let cell = viewController.collectionView?.cellForItem(at: indexPath) {
                    cells.append(cell)
                }
            }
        }
        
        return cells
    }

    override open func isEqual(_ o: Any?) -> Bool {
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
    
    func link(_ section: FOCollectionSection?, viewController: UIViewController?) {
        self.section = section
        self.viewController = viewController
    }
    
    open func widthForCollectionView(_ collectionView: UICollectionView, indexPath: IndexPath) -> CGFloat? {
        if let collectionViewLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout, let viewController = viewController as? UICollectionViewDelegateFlowLayout  {
            if let sectionInsets = viewController.collectionView?(collectionView, layout: collectionViewLayout, insetForSectionAt: indexPath.section),
                let minimumInterItemSpacing = viewController.collectionView?(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAt: indexPath.section),
                let sectionColumns = section?.columns {
                    let itemColumns = CGFloat(columns)
                    let columnWidth = (collectionView.frame.size.width - sectionInsets.left - sectionInsets.right - (CGFloat(sectionColumns) - CGFloat(1.0)) * minimumInterItemSpacing) / CGFloat(sectionColumns)
                    
                    return columnWidth * itemColumns + minimumInterItemSpacing * (itemColumns - 1)
            }
        }
        
        return nil
    }
    
}
