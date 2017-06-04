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
                t = delete($0, from: t, at: filter.index)
            }
            
            // Remove _from_ items for deletions
            filter.deletions?.forEach{
                m = delete($0, from: m, at: filter.index)
            }
            
            // Shift down _from_ items for deletions
            filter.deletions?.forEach{
                m = shift(-1, statePaths: m, for: $0, atIndex: filter.index)
            }
            
            // Shift up _from_ items for insertions
            filter.insertions?.forEach{
                m = shift(1, statePaths: m, for: $0, atIndex: filter.index)
            }
            
            // Move
            filter.moves?.forEach{
                mv in
                m = shift(-1, statePaths: m, for: mv.from, atIndex: filter.index)
                m = shift(1, statePaths: m, for: mv.to, atIndex: filter.index)
                m = move(statePaths: m, for: mv, atIndex: filter.index)
            }
        }
        
        // deletions
        update.deletions = deleted(m, to: t, at: index)
        
        update.deletions?.forEach {
            m = delete($0, from: m, at: index)
            m = shift(-1, statePaths: m, for: $0, atIndex: index)
        }
        
        // insertions
        update.insertions = deleted(t, to: m, at: index)

        update.insertions?.forEach {
            m = insert($0, into: m, at: index)
            m = shift(1, statePaths: m, for: $0, atIndex: index)
        }
        
        // moves
        update.moves = moves(m, to: t, at: index)
        
        // transform back to f indexPaths
        if let insertions = update.insertions {
            update.insertions = insertions.map({
                path -> StatePath in
                var new = path
                
                if let found = find(new, in: f, index: index).first {
                    new.indexPath = found.indexPath
                }
                
                return new
            })
        }
        
        if let deletions = update.deletions {
            update.deletions = deletions.map({
                path -> StatePath in
                var new = path
                
                if let found = find(new, in: f, index: index).first {
                    new.indexPath = found.indexPath
                }
                
                return new
            })
        }
        
        if let moves = update.moves {
            update.moves = moves.map({
                (move) -> Move in
                var new = move
                
                if let found = find(move.from, in: f, index: index).first {
                    new.from.indexPath = found.indexPath
                }
                
                return new
            })
        }
        
        // Filter out moves that don't go anywhere
        if let moves = update.moves {
            update.moves = moves.filter{
                $0.from.indexPath != $0.to.indexPath
            }
        }
        
        return update
    }
    
    func find(_ path: StatePath, in paths: [StatePath], index: Int) -> [StatePath] {
        return paths.filter{$0.identifierPath[0..<index] == path.identifierPath[0..<index]}
    }
    
    // up (+1), down (-1)
    func shift(_ value: Int, statePaths: [StatePath], for statePath: StatePath, atIndex index: Int) -> [StatePath] {
        var result = statePaths
        
        for i in 0..<result.count {
            let path = result[i]
            
            if
                path.indexPath[0..<index] == statePath.indexPath[0..<index],
                path.indexPath[index] >= statePath.indexPath[index],
                path.identifierPath[0..<index] != statePath.identifierPath[0..<index]
            {
                var newIndexPath = path.indexPath
                newIndexPath[index] = max(0, newIndexPath[index] + value)
                
                let newPath = StatePath(indexPath: newIndexPath, identifierPath: path.identifierPath)
                
                result.remove(at: i)
                result.insert(newPath, at: i)
            }
        }
        
        return result
    }
    
    func move(statePaths: [StatePath], for move: Move, atIndex index: Int) -> [StatePath] {
        return statePaths.map({
            (path) -> StatePath in
            var newPath = path
            
            if newPath.identifierPath[0...index] == move.from.identifierPath[0...index] {
                newPath.indexPath[0...index] = move.to.indexPath[0...index]
            }
            
            return newPath
        })
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
    
    func delete(_ path: StatePath, from paths: [StatePath], at index: Int) -> [StatePath] {
        return paths.filter{
            $0.identifierPath[0...index] != path.identifierPath[0...index]
        }
    }
    
    func insert(_ path: StatePath, into paths: [StatePath], at index: Int) -> [StatePath] {
        return paths + [path]
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
