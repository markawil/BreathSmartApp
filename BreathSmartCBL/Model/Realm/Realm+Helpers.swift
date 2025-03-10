//
//  Realm+Helpers.swift
//  BreathSmartCBL
//
//  Created by Mark Wilkinson on 3/9/25.
//

import RealmSwift
import Foundation

extension RealmManager {
    
    @discardableResult
    public func add<T>(object: T) -> Bool where T: Object {
        do {
            try self.realm.write {
                self.realm.add(object)
            }
        } catch let error {
            print("error adding realm object: \(error.localizedDescription)")
            return false
        }
        
        return true
    }
    
    @discardableResult
    public func update(_ execute: () -> Void) -> Bool {
        do {
            try self.realm.write {
                execute()
            }
        } catch let error {
            print("error updating realm object: \(error.localizedDescription)")
            return false
        }
        
        return true
    }
    
    @discardableResult
    public func delete<T>(object: T) -> Bool where T: Object {
        do {
            try self.realm.write {
                self.realm.delete(object)
            }
        } catch let error {
            print("error deleting realm object: \(error.localizedDescription)")
            return false
        }
        
        return true
    }
    
    @discardableResult
    public func deleteAll() -> Bool {
        do {
            try self.realm.write {
                self.realm.deleteAll()
            }
        } catch let error {
            print("error deleting all realm objects: \(error.localizedDescription)")
            return false
        }
        
        return true
    }
}
