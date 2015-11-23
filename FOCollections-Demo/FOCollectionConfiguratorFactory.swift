//
//  FOEmptyConfigurator.swift
//  FOCollectionsExamples
//
//  Created by Daniel Krofchick on 2015-11-09.
//  Copyright © 2015 Figure1. All rights reserved.
//

import Foundation
import UIKit

class FOCollectionItemConfigurator: FOCollectionConfigurator {
    
    override func configure(cell: UICollectionViewCell, collectionView: UICollectionView, indexPath: NSIndexPath) {
        cell.contentView.backgroundColor = UIColor.blueColor()
    }
    
}

class FOCollectionSectionConfigurator: FOCollectionConfigurator {
    override init() {
        super.init()
        
        item = FOCollectionItem()
    }
}
