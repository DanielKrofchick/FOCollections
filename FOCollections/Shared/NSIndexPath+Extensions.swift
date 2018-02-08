//
//  NSIndexPath+Extensions.swift
//  FOCollections
//
//  Created by Daniel Krofchick on 2015-11-23.
//  Copyright © 2015 Figure 1 Inc. All rights reserved.
//

import Foundation

extension IndexPath {
    
    static func indexPathsForItemsInRange(_ range: NSRange, section: Int) -> [IndexPath] {
        var result = [IndexPath]()
        
        for i in range.location ..< NSMaxRange(range) {
            result.append(IndexPath(item: i, section: section))
        }
        
        return result
    }
        
}
