//
//  NSIndexPath+Extensions.swift
//  FOCollections
//
//  Created by Daniel Krofchick on 2015-11-23.
//  Copyright © 2015 Figure1. All rights reserved.
//

import Foundation

extension NSIndexPath {
    
    class func indexPathsForItemsInRange(range: NSRange, section: Int) -> [NSIndexPath] {
        var result = [NSIndexPath]()
        
        for (var i = range.location; i < NSMaxRange(range); i++) {
            result.append(NSIndexPath(forItem: i, inSection: section))
        }
        
        return result
    }
        
}
