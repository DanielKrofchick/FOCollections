//
//  CollectionUpdater.swift
//  FOCollections
//
//  Created by Daniel Krofchick on 2017-05-23.
//  Copyright © 2017 Figure 1 Inc. All rights reserved.
//

import Foundation

struct CollectionUpdater {
    
    let from: [StatePath]
    let to: [StatePath]
    
    init(from: [StatePath], to: [StatePath]) {
        self.from = from
        self.to = to
    }
    
    func update(index: Int, filter: Update? = nil) -> Update {
        var update = Update(index: index)
        
        let f = Array(Set(from.flatMap{$0[0...index]}))
        var t = Array(Set(to.flatMap{$0[0...index]}))
        
        var m = f
        
        // This logic was designed to allow section and item updates at the same time,
        // but that doesn't work for many edge cases that result in two animations for the
        // same cell; i.e. a section moves, and an item in that section moves to another section.
        // Keeping this around for reference, but it is not being used and the logic may be a bit off.
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
                m = m.shift($0, by: -1, at: filter.index)
            }
            
            // Shift up _from_ items for insertions
            filter.insertions?.forEach{
                m = m.shift($0, by: 1, at: filter.index)
            }
            
            // Move
            filter.moves?.forEach{
                m = m.shift($0.from, by: -1, at: filter.index)
                m = m.shift($0.to, by: 1, at: filter.index)
                m = m.move($0, at: filter.index)
            }
        }
        
        // deletions
        update.deletions = m.deleted(to: t, at: index, map: nil).sorted()
        
        update.deletions?.forEach {
            m = m.delete($0, at: index)
            m = m.shift($0, by: -1, at: index)
        }
        
        // insertions
        update.insertions = t.deleted(to: m, at: index, map: nil).sorted()
        
        update.insertions?.forEach {
            m = m.insert(path: $0, at: index)
            m = m.shift($0, by: 1, at: index)
        }
        
        // moves
        update.moves = m.moves(to: t, at: index, map: nil)
        
        // transform back to f indexPaths
        if let insertions = update.insertions {
            let map = f.mapping()
            update.insertions = insertions.map{f.updateIndexPath($0, index: index, map: map)}
        }
        
        if let deletions = update.deletions {
            let map = f.mapping()
            update.deletions = deletions.map{f.updateIndexPath($0, index: index, map: map)}
        }
        
        if let moves = update.moves {
            let map = f.mapping()
            update.moves = moves.map{f.updateIndexPath($0, index: index, map: map)}
        }
        
        // Filter out moves that don't go anywhere
        if let moves = update.moves {
            update.moves = moves.filter{
                $0.from.indexPath != $0.to.indexPath
            }
        }
        
        return update
    }
    
}
