//
//  Array+Updater.swift
//  FOCollections
//
//  Created by Daniel Krofchick on 2017-06-06.
//  Copyright © 2017 Figure1. All rights reserved.
//

import Foundation

extension Array {
    
    func mapping() -> [IdentifierPath: StatePath] {
        var result = [IdentifierPath: StatePath]()
        
        for p in (self as! [StatePath]) {
            result[p.identifierPath] = p
        }
        
        return result
    }
    
    func find(_ path: StatePath, at index: Int, map: [IdentifierPath: StatePath]?) -> StatePath? {
        if
            let map = map
        {
            return map[path.identifierPath]
        }
        
        for p in (self as! [StatePath]) {
            if p.identifierPath[index] == path.identifierPath[index] {
                return p
            }
        }
        
        return nil
    }
    
    func updateIndexPath(_ path: StatePath, index: Int, map: [IdentifierPath: StatePath]?) -> StatePath  {
        let m = map ?? self.mapping()
        var result = path
        
        if
            let found = find(path, at: index, map: m)
        {
            result.indexPath = found.indexPath
        }
        
        return result
    }
    
    func updateIndexPath(_ move: Move, index: Int, map: [IdentifierPath: StatePath]?) -> Move  {
        var result = move
        
        if
            let found = find(move.from, at: index, map: map)
        {
            result.from.indexPath = found.indexPath
        }
        
        return result
    }
    
    func delete(_ path: StatePath, at index: Int) -> [StatePath] {
        var result = (self as! [StatePath])
        var offset: Int?
        
        for r in result.enumerated() {
            if r.element.identifierPath[0...index] == path.identifierPath[0...index] {
                offset = r.offset
                break
            }
        }
        
        if let offset = offset {
            result.remove(at: offset)
        }
        
        return result
    }
    
    func insert(path: StatePath, at index: Int) -> [StatePath] {
        return (self as! [StatePath]) + [path]
    }
    
    // up (+1), down (-1)
    func shift(_ path: StatePath, by: Int, at index: Int) -> [StatePath] {
        let pathA = path.indexPath[0..<index]
        let pathB = path.indexPath[index]
        let pathC = path.identifierPath[0..<index]
        
        return (self as! [StatePath]).map {
            p in
            if
                p.indexPath[0..<index] == pathA,
                p.indexPath[index] >= pathB,
                p.identifierPath[0..<index] != pathC
            {
                var newIndexPath = p.indexPath
                newIndexPath[index] = Swift.max(0, newIndexPath[index] + by)
                
                return StatePath(indexPath: newIndexPath, identifierPath: p.identifierPath)
            } else {
                return p
            }
        }
    }
    
    func move(_ move: Move, at index: Int) -> [StatePath] {
        return (self as! [StatePath]).map({
            (path) -> StatePath in
            var newPath = path
            
            if newPath.identifierPath[0...index] == move.from.identifierPath[0...index] {
                newPath.indexPath[0...index] = move.to.indexPath[0...index]
            }
            
            return newPath
        })
    }
    
    func moves(to: [StatePath], at index: Int, map: [IdentifierPath: StatePath]?) -> [Move] {
        let m = map ?? mapping()
        var moves = [Move]()
        
        to.forEach {
            tPath in
            if let fPath = find(tPath, at: index, map: m) {
                moves.append(Move(from: fPath, to: tPath))
            }
        }
        
        return moves
    }
    
    func deleted(to: [StatePath], at index: Int, map: [IdentifierPath: StatePath]?) -> [StatePath] {
        let m = map ?? to.mapping()
        
        return (self as! [StatePath]).filter{
            path in
            return to.find(path, at: index, map: m) == nil
        }
    }
    
}
