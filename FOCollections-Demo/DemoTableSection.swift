//
//  DemoTableSection.swift
//  FOCollections
//
//  Created by Daniel Krofchick on 2017-06-27.
//  Copyright © 2017 Figure1. All rights reserved.
//

import UIKit

class DemoTableSection: FOTableSection {
    
    var color = UIColor.white
    
    required init(identifier: String, color: UIColor = .white) {
        super.init()
        
        self.identifier = identifier
        self.color = color
    }
    
}

extension DemoTableSection {
    
    open override func copy() -> Any {
        let section = DemoTableSection(identifier: identifier!, color: color)
        section.items = items?.map{$0.copy()} as? [FOTableItem]
        
        return section
    }
    
}
