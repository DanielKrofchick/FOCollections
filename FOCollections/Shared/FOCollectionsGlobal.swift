//
//  FOCollectionsGlobal.swift
//  FOCollectionsExamples
//
//  Created by Daniel Krofchick on 2015-11-11.
//  Copyright © 2015 Figure 1 Inc. All rights reserved.
//

public enum PagingState: Int {
    case disabled
    case notPaging
    case paging
    case pagingAndFetching
    case finished
}

public enum PagingDirection: Int {
    case up
    case down
}

