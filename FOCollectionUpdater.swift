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

        update.deletions = deleted(f, to: t, at: index)
        update.insertions = deleted(t, to: f, at: index)

        if let deletions = update.deletions {
            m = delete(deletions, from: m)
        }

        if let insertions = update.insertions {
            m = insert(insertions, into: m)
        }

        update.moves = moves(m, to: t, at: index)
        
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
    
    func moves(_ a: [StatePath], to b: [StatePath], at index: Int) -> [Move] {
        var moves = [Move]()
        var m = a
//        var cont = true
        
//        while cont {
//            cont = false
            for i in 0..<m.count {
                let mPath = m[i]
                let bPath = b[i]
                
                if mPath != bPath {
                    if let foundI = indexOf(b: mPath, in: b, at: index) {
                        let foundMPath = b[foundI]
                        let mv = Move(from: mPath, to: foundMPath)
                        
                        moves.append(mv)
//                        m = move(mv, in: m, at: index).sorted()
//                        cont = true
//                        break
                    }
                }
            }
//        }
        
        return moves
    }
    
    func move(_ move: Move, in a: [StatePath], at index: Int) -> [StatePath] {
        var result = a
        
        if let i = indexOf(b: move.from, in: result, at: index) {
            result.remove(at: i)
            result.append(move.to)
        }
        
        for i in 0..<result.count {
            let path = result[i]
            
            if
                path.indexPath[0..<index] == move.to.indexPath[0..<index],
                path.indexPath[index] >= move.from.indexPath[index],
                path.indexPath[index] <= move.to.indexPath[index],
                path.identifierPath != move.to.identifierPath
            {
                var newIndexPath = path.indexPath
                newIndexPath[index] = newIndexPath[index] - 1
                
                if var newIdentifierPath = move.to.identifierPath[0...index - 1] {
                    newIdentifierPath.identifiers.append(path.identifierPath.identifiers[index])
                    
                    let newPath = StatePath(indexPath: newIndexPath, identifierPath: newIdentifierPath)
                    
                    result.remove(at: i)
                    result.insert(newPath, at: i)
                }
            }
        }
        
        return result
    }
    
    func indexOf(b: StatePath, in a: [StatePath], at index: Int) -> Int? {
        return a.enumerated().reduce([Int]()) { (result, element: (i: Int, aPath: StatePath)) -> [Int] in
            var r = result
            
            if element.aPath.identifierPath[index] == b.identifierPath[index] {
                r.append(element.i)
            }
            
            return r
        }.first
    }
    
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
