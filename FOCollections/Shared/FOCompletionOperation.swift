//
//  FOCompletionOperation.swift
//  Figure1
//
//  Created by Daniel Krofchick on 2015-05-17.
//  Copyright (c) 2015 Movable Science. All rights reserved.
//

import Foundation

class FOCompletionOperation: Operation {
    
    fileprivate var queue: DispatchQueue?
    fileprivate var work: ((_ operation: FOCompletionOperation) -> Void)? = nil
    
    convenience init(work: ((_ operation: FOCompletionOperation) -> Void)?, queue: DispatchQueue = DispatchQueue.global(qos: .default)) {
        self.init(queue: queue, work: work)
    }
    
    convenience init(queue: DispatchQueue?, work: ((_ operation: FOCompletionOperation) -> Void)?) {
        self.init()
        
        self.queue = queue
        self.work = work
    }

    fileprivate var _executing: Bool = false
    override var isExecuting: Bool {
        get {
            return _executing
        }
        set {
            if _executing != newValue {
                willChangeValue(forKey: "isExecuting")
                _executing = newValue
                didChangeValue(forKey: "isExecuting")
            }
        }
    }
    
    fileprivate var _finished: Bool = false;
    override var isFinished: Bool {
        get {
            return _finished
        }
        set {
            if _finished != newValue {
                willChangeValue(forKey: "isFinished")
                _finished = newValue
                didChangeValue(forKey: "isFinished")
            }
        }
    }
    
    fileprivate var _ready: Bool = true;
    override var isReady: Bool {
        get {
            return _ready && super.isReady
        }
        set {
            if _ready != newValue {
                willChangeValue(forKey: "isReady")
                _ready = newValue
                didChangeValue(forKey: "isReady")
            }
        }
    }
    
    override func main() {
        if isCancelled {
            finish()
            return
        }
        
        if queue != nil {
            queue!.async(execute: { () -> Void in
                self.work?(self)
            })
        } else {
            work?(self)
        }
    }
    
    func finish() {
        isExecuting = false
        isFinished = true
    }
    
}


