//
//  EventCenter.swift
//  SwiftPlusPlus
//
//  Created by Andrew J Wagner on 1/4/15.
//  Copyright (c) 2015 Drewag LLC. All rights reserved.
//

import Foundation

/**
    Protcol all events must implemenet to work with EventCenter
*/
public protocol EventType: class {
    associatedtype CallbackParam
}

/**
    A type safe, closure based event center modeled after NSNotificationCenter. Every event is guaranteed
    to be unique by the compiler because it is based off of a custom subclass that implements EventType.
    That protocol simply requires that the event define a typealias for the parameter to be passed to
    registered closures. That type can be `void`, a single type, or a multiple types by using a tuple.
    Because the EventCenter is type safe, when registering a callback, the types specified by the event
    can be inferred and enforced by the compiler.
*/
public class EventCenter {
    private var _observations = [String:CallbackCollection]()

    /**
        The main event center
    */
    public class func defaultCenter() -> EventCenter {
        return Static.DefaultInsance
    }
    
    public init() {}
    
    /**
        Trigger an event causing all registered callbacks to be called
    
        Callbacks are all executed on the same thread before this method returns
    
        - parameter event: the event to trigger
        - parameter params: the parameters to trigger the event with
    */
    public func triggerEvent<E: EventType>(event: E.Type, params: E.CallbackParam) {
        let key = NSStringFromClass(event)
        if let callbackCollection = self._observations[key] {
            for (_, callbacks) in callbackCollection {
                for spec in callbacks {
                    if let operationQueue = spec.operationQueue {
                        operationQueue.addOperationWithBlock {
                            (spec.callback as! (E.CallbackParam) -> ())(params)
                        }
                    }
                    else {
                        (spec.callback as! (E.CallbackParam) -> ())(params)
                    }
                }
            }
        }
    }
    
    /**
        Add a callback for when an event is triggered
    
        - parameter observer: observing object to be referenced later to remove the hundler
        - parameter event: the event to observe
        - parameter callback: callback to be called when the event is triggered
    */
    public func addObserver<E: EventType>(observer: AnyObject, forEvent event: E.Type, callback: (E.CallbackParam) -> ()) {
        self.addObserver(observer, forEvent: event, inQueue: nil, callback: callback)
    }
    
    /**
        Add a callback for when an event is triggered
    
        - parameter observer: observing object to be referenced later to remove the hundler
        - parameter forEvent: the event to observe
        - parameter inQueue: queue to call callback in (nil indicates the callback should be called on the same queue as the trigger)
        - parameter callback: callback to be called when the event is triggered
    */
    public func addObserver<E: EventType>(observer: AnyObject, forEvent event: E.Type, inQueue: NSOperationQueue?, callback: (E.CallbackParam) -> ()) {
        let key = NSStringFromClass(event)

        if self._observations[key] == nil {
            self._observations[key] = CallbackCollection()
        }
        addHandler((callback: callback, operationQueue: inQueue), toHandlerCollection: &self._observations[key]!, forObserver: observer)
    }
    
    /**
        Remove a callback for when an event is triggered
    
        - parameter observer: observing object passed in when registering the callback originally
        - parameter event: the event to remove the observer for
    */
    public func removeObserver<E: EventType>(observer: AnyObject, forEvent event: E.Type?) {
        if let event = event {
            let key = NSStringFromClass(event)
            if var callbackCollection = self._observations[key] {
                removecallbacksForObserver(observer, fromHandlerCollection: &callbackCollection)
                self._observations[key] = callbackCollection
            }
        }
    }
    
    /**
        Remove callbacks for all of the events that an observer is registered for
    
        - parameter observer: observing object passed in when registering the callback originally
    */
    public func removeObserverForAllEvents(observer: AnyObject) {
        for (key, var callbackCollection) in self._observations {
            removecallbacksForObserver(observer, fromHandlerCollection: &callbackCollection)
            self._observations[key] = callbackCollection
        }
    }
}

private extension EventCenter {
    private typealias Callback = Any
    private typealias CallbackSpec = (callback: Callback, operationQueue: NSOperationQueue?)
    private typealias CallbackCollection = [(observer: WeakWrapper, callbacks: [CallbackSpec])]

    private struct Static {
        static var DefaultInsance = EventCenter()
    }
}

private func addHandler(handler: EventCenter.CallbackSpec, inout toHandlerCollection collection: EventCenter.CallbackCollection, forObserver observer: AnyObject) {
    var found = false
    var index = 0
    for (possibleObserver, var callbacks) in collection {
        if possibleObserver.value === observer {
            callbacks.append(callback: handler.callback, operationQueue: handler.operationQueue)
            collection[index] = (possibleObserver, callbacks)
            found = true
            break
        }
        index += 1
    }
    
    if !found {
        collection.append((observer: WeakWrapper(observer), callbacks: [handler]))
    }
}

private func removecallbacksForObserver(observer: AnyObject, inout fromHandlerCollection collection: EventCenter.CallbackCollection) {
    var index = 0
    for (possibleObserver, _) in collection {
        if possibleObserver.value === observer {
            collection.removeAtIndex(index)
        }
        index += 1
    }
}
