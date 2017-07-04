//
//  Update.swift
//  FOCollections
//
//  Created by Daniel Krofchick on 2017-06-06.
//  Copyright © 2017 Figure1. All rights reserved.
//

struct Update {
    
    let index: Int
    var deletions: [StatePath]?
    var insertions: [StatePath]?
    var moves: [Move]?
    
    init(index: Int) {
        self.index = index
    }
    
}
