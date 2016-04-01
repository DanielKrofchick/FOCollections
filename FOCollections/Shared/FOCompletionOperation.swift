//
//  FOCompletionOperation.swift
//  Figure1
//
//  Created by Daniel Krofchick on 2015-05-17.
//  Copyright (c) 2015 Movable Science. All rights reserved.
//

import Foundation

class FOCompletionOperation: NSOperation {
    
    private var queue: dispatch_queue_t?
    private var work: ((operation: FOCompletionOperation) -> Void)? = nil

    convenience init(work: ((operation: FOCompletionOperation) -> Void)?, queue: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
        self.init(queue: queue, work: work)
    }
    
    convenience init(queue: dispatch_queue_t?, work: ((operation: FOCompletionOperation) -> Void)?) {
        self.init()
        
        self.queue = queue
        self.work = work
    }

    private var _executing: Bool = false
    override var executing: Bool {
        get {
            return _executing
        }
        set {
            if _executing != newValue {
                willChangeValueForKey("isExecuting")
                _executing = newValue
                didChangeValueForKey("isExecuting")
            }
        }
    }
    
    private var _finished: Bool = false;
    override var finished: Bool {
        get {
            return _finished
        }
        set {
            if _finished != newValue {
                willChangeValueForKey("isFinished")
                _finished = newValue
                didChangeValueForKey("isFinished")
            }
        }
    }
    
    private var _ready: Bool = true;
    override var ready: Bool {
        get {
            return _ready && super.ready
        }
        set {
            if _ready != newValue {
                willChangeValueForKey("isReady")
                _ready = newValue
                didChangeValueForKey("isReady")
            }
        }
    }
    
    override func main() {
        if cancelled {
            finish()
            return
        }
        
        if queue != nil {
            dispatch_async(queue!, { () -> Void in
                self.work?(operation: self)
            })
        } else {
            work?(operation: self)
        }
    }
    
    func finish() {
        executing = false
        finished = true
    }
    
}


