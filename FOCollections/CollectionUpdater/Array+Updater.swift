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
            let map = map,
            let result = map[path.identifierPath]
        {
            return result
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
            let _ = self as? [StatePath],
            let found = find(path, at: index, map: m)
        {
            result.indexPath = found.indexPath
        }
        
        return result
    }
    
    func updateIndexPath(_ move: Move, index: Int, map: [IdentifierPath: StatePath]?) -> Move  {
        var result = move
        
        if
            let _ = self as? [StatePath],
            let found = find(move.from, at: index, map: map)
        {
            result.from.indexPath = found.indexPath
        }
        
        return result
    }
    
    func delete(_ path: StatePath, at index: Int) -> [StatePath] {
        return (self as! [StatePath]).filter{
            $0.identifierPath[0...index] != path.identifierPath[0...index]
        }
    }
    
    func insert(path: StatePath, at index: Int) -> [StatePath] {
        return (self as! [StatePath]) + [path]
    }
    
    // up (+1), down (-1)
    func shift(_ path: StatePath, by: Int, at index: Int) -> [StatePath] {
        var result = self as! [StatePath]
        
        for i in 0..<result.count {
            let p = result[i]
            
            if
                p.indexPath[0..<index] == path.indexPath[0..<index],
                p.indexPath[index] >= path.indexPath[index],
                p.identifierPath[0..<index] != path.identifierPath[0..<index]
            {
                var newIndexPath = p.indexPath
                newIndexPath[index] = Swift.max(0, newIndexPath[index] + by)
                
                let newPath = StatePath(indexPath: newIndexPath, identifierPath: p.identifierPath)
                
                result.remove(at: i)
                result.insert(newPath, at: i)
            }
        }
        
        return result
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
        let m = map ?? to.mapping()
        var moves = [Move]()
        
        (self as! [StatePath]).forEach {
            fPath in
            if let tPath = find(fPath, at: index, map: m) {
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
