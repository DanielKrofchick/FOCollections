//
//  FOCollectionPagingConfigurator.swift
//  Figure1
//
//  Created by Daniel Krofchick on 2015-05-07.
//  Copyright (c) 2015 Movable Science. All rights reserved.
//

import UIKit

public class FOCollectionPagingConfigurator: FOCollectionConfigurator {
    override public func configure(cell: UICollectionViewCell, collectionView: UICollectionView, indexPath: NSIndexPath) {
        cell.contentView.backgroundColor = UIColor.redColor()
    }
    
}
