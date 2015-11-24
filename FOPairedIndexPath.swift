//
//  FOPairedIndexPath.swift
//  FOCollections
//
//  Created by Daniel Krofchick on 2015-11-23.
//  Copyright © 2015 Figure1. All rights reserved.
//

import Foundation

// Sorts by index path with a paired object.

class FOPairedIndexPath<T: AnyObject>: Equatable {
    
    let object: T!
    let indexPath: NSIndexPath!
    
    init(object: T, indexPath: NSIndexPath) {
        self.object = object
        self.indexPath = indexPath
    }
    
    class func pairedIndexPaths(objects: [T], indexPaths: [NSIndexPath]) -> [FOPairedIndexPath<T>] {
        assert(objects.count == indexPaths.count, "attempting to created pairedIndexPaths with \(objects.count) data and \(indexPaths.count) indexPaths")
        
        var result = [FOPairedIndexPath]()
        
        for (index, object) in objects.enumerate() {
            result.append(FOPairedIndexPath(object: object, indexPath: indexPaths[index]))
        }
        
        return result
    }
    
    class func unpairedIndexPaths(pairedIndexPaths: [FOPairedIndexPath]) -> ([T], [NSIndexPath]) {
        var unpairedObjects = [T]()
        var unpairedIndexPaths = [NSIndexPath]()
        
        for pairedIndexPath in pairedIndexPaths {
            unpairedObjects.append(pairedIndexPath.object)
            unpairedIndexPaths.append(pairedIndexPath.indexPath)
        }
        
        return (unpairedObjects, unpairedIndexPaths)
    }
    
}

func ==<T>(lhs: FOPairedIndexPath<T>, rhs: FOPairedIndexPath<T>) -> Bool {
    return lhs.indexPath == rhs.indexPath
}

func <<T>(lhs: FOPairedIndexPath<T>, rhs: FOPairedIndexPath<T>) -> Bool {
    return lhs.indexPath < rhs.indexPath
}

func ><T>(lhs: FOPairedIndexPath<T>, rhs: FOPairedIndexPath<T>) -> Bool {
    return lhs.indexPath > rhs.indexPath
}

private func <(lhs: NSIndexPath, rhs: NSIndexPath) -> Bool {
    return lhs.section < rhs.section || (lhs.section == rhs.section && lhs.item < rhs.item)
}

private func >(lhs: NSIndexPath, rhs: NSIndexPath) -> Bool {
    return lhs.section > rhs.section || (lhs.section == rhs.section && lhs.item > rhs.item)
}
