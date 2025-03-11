//
//  RealmManager.swift
//  BreathSmartCBL
//
//  Created by Mark Wilkinson on 3/9/25.
//

import RealmSwift
import Foundation

/*
 A class that manages a Realm instance.
 */
class RealmManager {
    
    private var useInMemory: Bool
    
    init(useInMemory: Bool = false, deleteAllOnLaunch: Bool = false) {
        self.useInMemory = useInMemory
        
        if deleteAllOnLaunch {
            deleteAll()
        }
    }
    
    // increment for model changes
    fileprivate static let dbSchemaVersion: UInt64 = 1
    
    // usable if we want a file-based version of Realm instead of in-memory
    private var configuration: Realm.Configuration {
        guard !useInMemory else { return .defaultConfiguration }
        
        let config = Realm.Configuration(
            fileURL: fileURL,
            schemaVersion: RealmManager.dbSchemaVersion,
            migrationBlock: { migration, oldSchemaVersion in
                // put migration code here if needed
            })
        Realm.Configuration.defaultConfiguration = config
        
        return config
    }
        
    public var realm: Realm {
        guard let realm = try? Realm(configuration: configuration) else {
            fatalError("Could not load Realm.")
        }
        
        return realm
    }
    
    private var fileURL: URL? {
        let appName = Bundle.main.bundleIdentifier ?? "BreatheSmartApp"
        guard let realmDirectory = try? FileManager.default.url(for: .documentDirectory,
                                                        in: .userDomainMask,
                                                        appropriateFor: nil,
                                                        create: true).appendingPathComponent("realm", isDirectory: true) else {
            fatalError("Couldn't get the realm directory URL")
        }
        
        let url = realmDirectory.appendingPathComponent("\(appName).realm")
        if !FileManager.default.fileExists(atPath: realmDirectory.path()) {
            try? FileManager.default.createDirectory(at: realmDirectory, withIntermediateDirectories: true)
            if !FileManager.default.fileExists(atPath: realmDirectory.path()) {
                fatalError("Couldn't create the realm file directory.")
            }
        }
        
        return url
    }
    
    // convenience method to delete realm file completely.
    public func deleteRealmFile() {
        guard let url = fileURL else {
            return
        }
        
        do {
            let filePathExists = FileManager.default.fileExists(atPath: fileURL?.path() ?? "")
            if filePathExists {
                try FileManager.default.removeItem(at: url)
            }
        } catch let error {
            print("Couldn't delete the realm file when asked to, reason: \(error.localizedDescription)")
        }
    }
}
