//
//  DependencyResolver.swift
//  BreathSmartCBL
//
//  Created by Mark Wilkinson on 3/9/25.
//

import Foundation

// Example dependency resolver for dependency injection
class DependencyResolver {
    
    static let shared = DependencyResolver()
    
    private var _map = [String: AnyObject]()
    
    func register<T>(instance: T) {
        let typeString = String(describing: T.self)
        _map[typeString] = instance as AnyObject
    }
    
    func resolve<T>() -> T {
        let typeString = String(describing: T.self)
        return _map[typeString] as! T
    }
}
