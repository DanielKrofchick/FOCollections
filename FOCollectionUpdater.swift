//
//  FOCollectionUpdater.swift
//  FOCollections
//
//  Created by Daniel Krofchick on 2017-05-23.
//  Copyright © 2017 Figure1. All rights reserved.
//

import Foundation

extension FOTableViewDataSource {
    
    func statePaths() -> [StatePath] {
        var result = [StatePath]()
        
        enumerated().forEach {
            (index, item) in
            if
                let indexPath = self.indexPathsForItem(item).first,
                let identifierPath = self.indentifierPath(indexPath: indexPath)
            {
                result.append(StatePath(indexPath: indexPath, identifierPath: identifierPath))
            }
        }
        
        return result
    }
    
    func statePaths(sections: [FOTableSection]) -> [StatePath] {
        var result = [StatePath]()
        
        sections.enumerated().forEach {
            (sectionIndex, section) in
            section.items?.enumerated().forEach({
                (itemIndex, item) in
                if
                    let sectionID = section.identifier,
                    let itemID = item.identifier
                {
                    let identifierPath = IdentifierPath(identifiers: [sectionID, itemID])
                    let indexPath = IndexPath(item: itemIndex, section: sectionIndex)
                    
                    result.append(StatePath(indexPath: indexPath, identifierPath: identifierPath))
                }
            })
        }
        
        return result
    }
    
    func indentifierPath(indexPath: IndexPath) -> IdentifierPath? {
        var result: IdentifierPath?
        
        if
            let sectionID = sectionAtIndex(indexPath.section)?.identifier,
            let itemID = itemAtIndexPath(indexPath)?.identifier
        {
            result = IdentifierPath(identifiers: [sectionID, itemID])
        }
        
        return result
    }
    
}

extension Array {
    
    func find(_ path: StatePath, at index: Int) -> [StatePath] {
        return (self as! [StatePath]).filter{
            $0.identifierPath[0..<index] == path.identifierPath[0..<index]
        }
    }
    
    func updateIndexPath( _ path: StatePath, index: Int) -> StatePath  {
        var result = path
        
        if
            let _ = self as? [StatePath],
            let found = find(path, at: index).first
        {
            result.indexPath = found.indexPath
        }
        
        return result
    }
    
    func updateIndexPath( _ move: Move, index: Int) -> Move  {
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
    func shift(_ path: StatePath, by: Int, atIndex index: Int) -> [StatePath] {
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
    
    func move(_ move: Move, atIndex index: Int) -> [StatePath] {
        return (self as! [StatePath]).map({
            (path) -> StatePath in
            var newPath = path
            
            if newPath.identifierPath[0...index] == move.from.identifierPath[0...index] {
                newPath.indexPath[0...index] = move.to.indexPath[0...index]
            }
            
            return newPath
        })
    }
    
}

struct FOCollectionUpdater {
    
    let from: [StatePath]
    let to: [StatePath]
    
    init(from: [StatePath], to: [StatePath]) {
        self.from = from
        self.to = to
    }
    
    func update(index: Int, filter: Update? = nil) -> Update {
        var update = Update(index: index)
        
        let f = Array(Set(from.map{$0[0...index]!}.filter{$0 != nil}))
        var t = Array(Set(to.map{$0[0...index]!}.filter{$0 != nil}))
        
        var m = f
        
        if let filter = filter {
            // Remove _to_ items for insertions
            filter.insertions?.forEach{
                t = t.delete($0, at: filter.index)
            }
            
            // Remove _from_ items for deletions
            filter.deletions?.forEach{
                m = m.delete($0, at: filter.index)
            }
            
            // Shift down _from_ items for deletions
            filter.deletions?.forEach{
                m = m.shift($0, by: -1, atIndex: filter.index)
            }
            
            // Shift up _from_ items for insertions
            filter.insertions?.forEach{
                m = m.shift($0, by: 1, atIndex: filter.index)
            }
            
            // Move
            filter.moves?.forEach{
                mv in
                m = m.shift(mv.from, by: -1, atIndex: filter.index)
                m = m.shift(mv.to, by: 1, atIndex: filter.index)
                m = m.move(mv, atIndex: filter.index)
            }
        }
        
        // deletions
        update.deletions = deleted(m, to: t, at: index)
        
        update.deletions?.forEach {
            m = m.delete($0, at: index)
            m = m.shift($0, by: -1, atIndex: index)
        }
        
        // insertions
        update.insertions = deleted(t, to: m, at: index)

        update.insertions?.forEach {
            m = m.insert(path: $0, at: index)
            m = m.shift($0, by: 1, atIndex: index)
        }
        
        // moves
        update.moves = moves(m, to: t, at: index)
        
        // transform back to f indexPaths
        if let insertions = update.insertions {
            update.insertions = insertions.map{f.updateIndexPath($0, index: index)}
        }
        
        if let deletions = update.deletions {
            update.deletions = deletions.map{f.updateIndexPath($0, index: index)}
        }
        
        if let moves = update.moves {
            update.moves = moves.map{f.updateIndexPath($0, index: index)}
        }
        
        // Filter out moves that don't go anywhere
        if let moves = update.moves {
            update.moves = moves.filter{
                $0.from.indexPath != $0.to.indexPath
            }
        }
        
        return update
    }
    
    func deleted(_ a: [StatePath], to b: [StatePath], at index: Int) -> [StatePath] {
        return a.filter{
            aPath in
            return b.filter{
                bPath in
                aPath.identifierPath[index] == bPath.identifierPath[index]
            }.count == 0
        }
    }
    
    func moves(_ from: [StatePath], to: [StatePath], at index: Int) -> [Move] {
        var moves = [Move]()
        
        to.forEach {
            tPath in
            if let fIndex = indexOf(tPath, in: from, at: index) {
                let fPath = from[fIndex]
                
                if fPath != tPath {
                    moves.append(Move(from: fPath, to: tPath))
                }
            }
        }
        
        return moves
    }
    
    func indexOf(_ path: StatePath, in paths: [StatePath], at index: Int) -> Int? {
        return paths.enumerated().reduce([Int]()) { (result, element: (i: Int, aPath: StatePath)) -> [Int] in
            var r = result
            
            if element.aPath.identifierPath[index] == path.identifierPath[index] {
                r.append(element.i)
            }
            
            return r
        }.first
    }
    
}

struct Update {
    
    let index: Int
    var deletions: [StatePath]?
    var insertions: [StatePath]?
    var moves: [Move]?
    
    init(index: Int) {
        self.index = index
    }
    
}

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
            return indexPath.hashValue + identifierPath.hashValue
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

struct IdentifierPath {
    
    var identifiers: [String]
    
    init(identifiers: [String]) {
        self.identifiers = identifiers
    }
    
    init(item: String, section: String) {
        self.identifiers = [section, item]
    }
    
    public subscript(range: CountableClosedRange<Int>) -> IdentifierPath? {
        if range.lowerBound < 0 || range.upperBound > identifiers.count || identifiers.count == 0 {
            return nil
        } else {
            return IdentifierPath(identifiers: Array(identifiers[range]))
        }
    }
    
    public subscript(index: Int) -> IdentifierPath? {
        return self[index...index]
    }
    
    public subscript(range: CountableRange<Int>) -> IdentifierPath {
        var result = [String]()
        
        identifiers.enumerated().forEach {
            (index, identifier) in
            if index >= range.lowerBound && index <= range.upperBound {
                result.append(identifier)
            }
        }
        
        return IdentifierPath(identifiers: result)
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

struct Move {
    
    var from: StatePath
    var to: StatePath
    
    init(from: StatePath, to: StatePath) {
        self.from = from
        self.to = to
    }
    
}
