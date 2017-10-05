//
//  StatePath.swift
//  FOCollections
//
//  Created by Daniel Krofchick on 2017-06-06.
//  Copyright © 2017 Figure1. All rights reserved.
//

import Foundation

struct StatePath {
    
    var indexPath: IndexPath
    let identifierPath: IdentifierPath
    
    init(indexPath: IndexPath, identifierPath: IdentifierPath) {
        self.indexPath = indexPath
        self.identifierPath = identifierPath
    }
    
    public subscript(range: CountableClosedRange<Int>) -> StatePath? {
        if let newIdentifierPath = identifierPath[range] {
            return StatePath(indexPath: indexPath[range], identifierPath: newIdentifierPath)
        } else {
            return nil
        }
    }
    
    public subscript(index: Int) -> StatePath? {
        return self[index...index]
    }
    
}

extension StatePath: Hashable {
    
    var hashValue: Int {
        get {
            return indexPath.hashValue ^ identifierPath.hashValue
        }
    }
}

extension StatePath: Equatable {
    
    public static func ==(lhs: StatePath, rhs: StatePath) -> Bool {
        return lhs.indexPath == rhs.indexPath && lhs.identifierPath == rhs.identifierPath
    }
    
}

extension StatePath: Comparable {
    
    public static func <(lhs: StatePath, rhs: StatePath) -> Bool {
        return lhs.indexPath < rhs.indexPath
    }
    
    public static func <=(lhs: StatePath, rhs: StatePath) -> Bool {
        return lhs.indexPath <= rhs.indexPath
    }
    
    public static func >(lhs: StatePath, rhs: StatePath) -> Bool {
        return lhs.indexPath > rhs.indexPath
    }
    
    public static func >=(lhs: StatePath, rhs: StatePath) -> Bool {
        return lhs.indexPath >= rhs.indexPath
    }
    
}

extension StatePath: CustomStringConvertible {
    
    public var description: String {
        return "{indexPath: \(indexPath), identifierPath: \(identifierPath)}"
    }
    
}
