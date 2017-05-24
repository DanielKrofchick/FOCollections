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
    
    func update(index: Int) -> Update {
        var update = Update()
        
        let f = from.map{$0[0...index]}.filter{$0 != nil} as! [StatePath]
        let t = to.map{$0[0...index]}.filter{$0 != nil} as! [StatePath]
        
        var m = f

        update.deletions = deleted(f, to: t, index: index)
        update.insertions = deleted(t, to: f, index: index)

        if let deletions = update.deletions {
            m = delete(deletions, from: m)
        }

        if let insertions = update.insertions {
            m = insert(insertions, into: m)
        }

//        update.moves = moves(m, to: f)
        
        return update
    }
    
    func deleted(_ a: [StatePath], to b: [StatePath], index: Int) -> [StatePath] {
        return a.filter{
            aPath in
            return b.filter{
                bPath in
                aPath.identifierPath[index] == bPath.identifierPath[index]
            }.count == 0
        }
    }
    
    func delete(_ a: [StatePath], from b: [StatePath]) -> [StatePath] {
        var result = b
        
        a.forEach {
            statePath in
            if let index = result.index(of: statePath) {
                result.remove(at: index)
            }
        }
        
        return result
    }
    
    func insert(_ a: [StatePath], into b: [StatePath]) -> [StatePath] {
        return (a + b).sorted()
    }
    
//
//    func moves(_ a: [State], to b: [State]) -> [Move] {
//        var moves = [Move]()
//        var m = a
//        
//        for i in (0..<b.count).reversed() {
//            if
//                let bS = find(index: i, in: b),
//                let aS = find(identifier: bS.identifier, in: m)
//            {
//                if aS.index != bS.index {
//                    moves.append(Move(from: aS, to: bS))
//                }
//            }
//        }
//        
//        return moves
//    }
//    
//    func find(index: Int, in a: [State]) -> State? {
//        return a.filter{$0.index == index}.first
//    }
//    
//    func find(identifier: String, in a: [State]) -> State? {
//        return a.filter{$0.identifier == identifier}.first
//    }
    
}

struct Update {
    
    var position: Int? = nil
    var deletions: [StatePath]? = nil
    var insertions: [StatePath]? = nil
    var moves: [Move]? = nil
    
}

struct StatePath {
    
    let indexPath: IndexPath
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
    
    let identifiers: [String]
    
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
