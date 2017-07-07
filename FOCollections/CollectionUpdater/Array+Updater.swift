//
//  Array+Updater.swift
//  FOCollections
//
//  Created by Daniel Krofchick on 2017-06-06.
//  Copyright © 2017 Figure1. All rights reserved.
//

import Foundation

extension Array {
    
    func find(_ path: StatePath, at index: Int) -> StatePath? {
        for p in (self as! [StatePath]) {
            if p.identifierPath[index] == path.identifierPath[index] {
                return p
            }
        }
        
        return nil
    }
    
    func updateIndexPath(_ path: StatePath, index: Int) -> StatePath  {
        var result = path
        
        if
            let _ = self as? [StatePath],
            let found = find(path, at: index)
        {
            result.indexPath = found.indexPath
        }
        
        return result
    }
    
    func updateIndexPath(_ move: Move, index: Int) -> Move  {
        var result = move
        
        if
            let _ = self as? [StatePath],
            let found = find(move.from, at: index)
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
        
    func moves(to: [StatePath], at index: Int) -> [Move] {
        var moves = [Move]()
        
        to.forEach {
            tPath in
            if let fPath = find(tPath, at: index) {
                moves.append(Move(from: fPath, to: tPath))
            }
        }
        
        return moves
    }
    
    func deleted(to: [StatePath], at index: Int) -> [StatePath] {
        return (self as! [StatePath]).filter{
            aPath in
            return to.filter{
                toPath in
                aPath.identifierPath[index] == toPath.identifierPath[index]
                }.count == 0
        }
    }
    
}
