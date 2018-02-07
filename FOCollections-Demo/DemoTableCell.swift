//
//  DemoTableCell.swift
//  FOCollections
//
//  Created by Daniel Krofchick on 2017-06-27.
//  Copyright © 2017 Figure 1 Inc. All rights reserved.
//

import UIKit

class DemoTableCell: UITableViewCell {
    
    let indicator = UIView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        indicator.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        accessoryView = indicator
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        backgroundColor = .orange
        indicator.backgroundColor = .orange
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
