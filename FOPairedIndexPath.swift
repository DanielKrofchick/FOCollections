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
    let indexPath: IndexPath!
    
    init(object: T, indexPath: IndexPath) {
        self.object = object
        self.indexPath = indexPath
    }
    
    class func pairedIndexPaths(_ objects: [T], indexPaths: [IndexPath]) -> [FOPairedIndexPath<T>] {
        assert(objects.count == indexPaths.count, "attempting to created pairedIndexPaths with \(objects.count) data and \(indexPaths.count) indexPaths")
        
        var result = [FOPairedIndexPath]()
        
        for (index, object) in objects.enumerated() {
            result.append(FOPairedIndexPath(object: object, indexPath: indexPaths[index]))
        }
        
        return result
    }
    
    class func unpairedIndexPaths(_ pairedIndexPaths: [FOPairedIndexPath]) -> ([T], [IndexPath]) {
        var unpairedObjects = [T]()
        var unpairedIndexPaths = [IndexPath]()
        
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
    return lhs.indexPath.compare(rhs.indexPath) == .orderedAscending
}

func ><T>(lhs: FOPairedIndexPath<T>, rhs: FOPairedIndexPath<T>) -> Bool {
    return lhs.indexPath.compare(rhs.indexPath) == .orderedDescending
}

private func <(lhs: IndexPath, rhs: IndexPath) -> Bool {
    return lhs.section < rhs.section || (lhs.section == rhs.section && lhs.item < rhs.item)
}

private func >(lhs: IndexPath, rhs: IndexPath) -> Bool {
    return lhs.section > rhs.section || (lhs.section == rhs.section && lhs.item > rhs.item)
}
