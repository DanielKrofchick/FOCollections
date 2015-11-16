//
//  FOCollectionConfigurator.swift
//  FOCollections
//
//  Created by Daniel Krofchick on 2015-11-08.
//  Copyright © 2015 Figure1. All rights reserved.
//

import UIKit

public class FOCollectionConfigurator: NSObject, FOCollectionConfiguratorProtocol {
    
    weak public var item: FOCollectionItem? = nil
    weak public var viewController: UIViewController? = nil
    
    public func configure(cell: UICollectionViewCell, collectionView: UICollectionView, indexPath: NSIndexPath){}
    public func getExtras(collectionView: UICollectionView, indexPath: NSIndexPath){}
    public func setExtras(collectionView: UICollectionView, indexPath: NSIndexPath, extras: [NSObject: AnyObject]){}
    
}

public protocol FOCollectionConfiguratorProtocol: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    weak var item: FOCollectionItem? {get set}
    weak var viewController: UIViewController? {get set}
    
    func configure(cell: UICollectionViewCell, collectionView: UICollectionView, indexPath: NSIndexPath)
    func getExtras(collectionView: UICollectionView, indexPath: NSIndexPath)
    func setExtras(collectionView: UICollectionView, indexPath: NSIndexPath, extras: [NSObject: AnyObject])
    
}
