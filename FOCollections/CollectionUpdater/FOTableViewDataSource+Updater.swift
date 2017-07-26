//
//  FOTableViewDataSource+Updater.swift
//  FOCollections
//
//  Created by Daniel Krofchick on 2017-06-06.
//  Copyright © 2017 Figure1. All rights reserved.
//

import Foundation

extension FOTableViewDataSource {
    
    func statePaths(sections: [FOTableSection]) -> [StatePath] {
        var result = [StatePath]()
        
        sections.enumerated().forEach {
            (sectionIndex, section) in
            if let sectionID = section.identifier {
                if section.items?.isEmpty == false {
                    section.items?.enumerated().forEach({
                        (itemIndex, item) in
                        if let itemID = item.identifier {
                            let identifierPath = IdentifierPath(identifiers: [sectionID, itemID])
                            let indexPath = IndexPath(item: itemIndex, section: sectionIndex)
                            
                            result.append(StatePath(indexPath: indexPath, identifierPath: identifierPath))
                        }
                    })
                } else {
                    result.append(StatePath(indexPath: IndexPath(index: sectionIndex), identifierPath: IdentifierPath(identifiers: [sectionID])))
                }
            }
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
