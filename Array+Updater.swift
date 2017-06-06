//
//  Array+Updater.swift
//  FOCollections
//
//  Created by Daniel Krofchick on 2017-06-06.
//  Copyright © 2017 Figure1. All rights reserved.
//

import Foundation

extension Array {
    
    func find(_ path: StatePath, at index: Int) -> [StatePath] {
        return (self as! [StatePath]).filter{
            $0.identifierPath[0..<index] == path.identifierPath[0..<index]
        }
    }
    
    func updateIndexPath(_ path: StatePath, index: Int) -> StatePath  {
        var result = path
        
        if
            let _ = self as? [StatePath],
            let found = find(path, at: index).first
        {
            result.indexPath = found.indexPath
        }
        
        return result
    }
    
    func updateIndexPath(_ move: Move, index: Int) -> Move  {
        var result = move
        
        if
            let _ = self as? [StatePath],
            let found = find(move.from, at: index).first
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
    
    func indexOf(_ path: StatePath, at index: Int) -> Int? {
        return (self as! [StatePath]).enumerated().reduce([Int]()) { (result, element: (i: Int, aPath: StatePath)) -> [Int] in
            var r = result
            
            if element.aPath.identifierPath[index] == path.identifierPath[index] {
                r.append(element.i)
            }
            
            return r
            }.first
    }
    
    func moves(to: [StatePath], at index: Int) -> [Move] {
        var moves = [Move]()
        
        to.forEach {
            tPath in
            if let fIndex = indexOf(tPath, at: index) {
                let fPath = (self as! [StatePath])[fIndex]
                
                if fPath != tPath {
                    moves.append(Move(from: fPath, to: tPath))
                }
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
