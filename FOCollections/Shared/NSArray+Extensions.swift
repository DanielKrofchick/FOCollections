//
//  NSArray+Extensions.swift
//  FOCollections
//
//  Created by Daniel Krofchick on 2015-11-05.
//  Copyright © 2015 Figure1. All rights reserved.
//

extension Array {
    
    // Safely lookup an index that might be out of bounds,
    // returning nil if it does not exist
    func safe(_ index: Int) -> Element? {
        if 0 <= index && index < count {
            return self[index]
        } else {
            return nil
        }
    }
    
}
