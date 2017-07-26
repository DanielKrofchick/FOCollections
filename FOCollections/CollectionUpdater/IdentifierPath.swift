//
//  IdentifierPath.swift
//  FOCollections
//
//  Created by Daniel Krofchick on 2017-06-06.
//  Copyright © 2017 Figure1. All rights reserved.
//

import Foundation

struct IdentifierPath {
    
    var identifiers: [String]
    fileprivate var cache = NSCache<NSString, iPath>()
    
    init(identifiers: [String]) {
        self.identifiers = identifiers
    }
    
    init(item: String, section: String) {
        self.identifiers = [section, item]
    }
    
    public subscript(range: CountableClosedRange<Int>) -> IdentifierPath? {
        if range.lowerBound < 0 || range.upperBound >= identifiers.count || identifiers.count == 0 {
            return nil
        } else {
            if let c = cache.object(forKey: String(describing: range) as NSString) {
                return c.x
            }
            
            let path = IdentifierPath(identifiers: Array(identifiers[range]))
            
            cache.setObject(iPath(x: path), forKey: String(describing: range) as NSString)
            
            return path
        }
    }
    
    public subscript(index: Int) -> IdentifierPath? {
        return self[index...index]
    }
    
    public subscript(range: CountableRange<Int>) -> IdentifierPath? {
        if range.lowerBound < 0 || range.upperBound >= identifiers.count || identifiers.count == 0 {
            return nil
        } else {
            if let c = cache.object(forKey: String(describing: range) as NSString) {
                return c.x
            }
            
            let path = IdentifierPath(identifiers: Array(identifiers[range]))
            
            cache.setObject(iPath(x: path), forKey: String(describing: range) as NSString)
            
            return path
        }
    }
    
}

private class iPath: NSObject {
    
    var x: IdentifierPath!
    
    required init(x: IdentifierPath) {
        super.init()
        
        self.x = x
    }
    
}

extension IdentifierPath: Hashable {
    
    var hashValue: Int {
        get {
            return identifiers.reduce("", {
                (result, value) -> String in
                return result + value
            }).hashValue
        }
    }
    
}

extension IdentifierPath: Equatable {
    
    public static func ==(lhs: IdentifierPath, rhs: IdentifierPath) -> Bool {
        guard
            lhs.identifiers.count == rhs.identifiers.count
            else {
                return false
        }
        
        return lhs.identifiers == rhs.identifiers
    }
    
}

extension IdentifierPath: CustomStringConvertible {
    
    public var description: String {
        return String(describing: identifiers)
    }
    
}
