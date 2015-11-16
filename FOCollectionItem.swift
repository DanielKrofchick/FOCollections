//
//  FOCollectionItem.swift
//  Figure1
//
//  Created by Daniel Krofchick on 2015-04-18.
//  Copyright (c) 2015 Movable Science. All rights reserved.
//

import UIKit

public class FOCollectionItem: NSObject {

    public var data: AnyObject? = nil                                              // Data cargo
    public var identifier: String? = nil                                           // Unique item ID
    public var reuseIdentifier: String? = nil                                      // collectionView reuseIdentifier
    public var cellClass: AnyClass? = nil                                          // View Class to register with the collectionView
    public var configurator: FOCollectionConfigurator? = nil                       // Configures the cell and perfroms action on controller events
    public var columns = Int(1)
    public weak var section: FOCollectionSection?                                  // Weak reference to section
    
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
        configurator?.item = self
        configurator?.viewController = viewController
    }
    
    public func widthForCollectionView(collectionView: UICollectionView, indexPath: NSIndexPath) -> CGFloat? {
        if let collectionViewLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout, viewController = configurator?.viewController as? UICollectionViewDelegateFlowLayout  {
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
