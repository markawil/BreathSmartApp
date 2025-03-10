////
////  RealmManager.swift
////  BreathSmartCBL
////
////  Created by Mark Wilkinson on 3/9/25.
////
//
//import RealmSwift
//import Foundation
//
//class RealmManager {
//    
//    public static let shared = RealmManager()
//    
//    // there can be only 1
//    private init() { }
//    
//    // increment for model changes
//    fileprivate static let dbSchemaVersion: UInt64 = 1
//    
//    private var configuration: Realm.Configuration {
//        let config = Realm.Configuration(
//            fileURL: fileURL,
//            schemaVersion: RealmManager.dbSchemaVersion,
//            migrationBlock: { migration, oldSchemaVersion in
//                // put migration code here if needed
//            })
//        Realm.Configuration.defaultConfiguration = config
//        
//        return config
//    }
//        
//    public var realm: Realm {
//        guard let realm = try? Realm(configuration: configuration) else {
//            fatalError("Could not load Realm file.")
//        }
//        
//        return realm
//    }
//    
//    private var fileURL: URL? {
//        let appName = Bundle.main.bundleIdentifier ?? "BreatheSmartApp"
//        guard let realmDirectory = try? FileManager.default.url(for: .documentDirectory,
//                                                        in: .userDomainMask,
//                                                        appropriateFor: nil,
//                                                        create: true).appendingPathComponent("realm", isDirectory: true) else {
//            fatalError("Couldn't get the realm directory URL")
//        }
//        
//        let url = realmDirectory.appendingPathComponent("\(appName).realm")
//        if !FileManager.default.fileExists(atPath: realmDirectory.path()) {
//            try? FileManager.default.createDirectory(at: realmDirectory, withIntermediateDirectories: true)
//            if !FileManager.default.fileExists(atPath: realmDirectory.path()) {
//                fatalError("Couldn't create the realm file directory.")
//            }
//        }
//        
//        return url
//    }
//    
//    // convenience method to delete realm file completely.
//    public func deleteRealmFile() {
//        guard let url = fileURL else {
//            return
//        }
//        
//        do {
//            let filePathExists = FileManager.default.fileExists(atPath: fileURL?.path() ?? "")
//            if filePathExists {
//                try FileManager.default.removeItem(at: url)
//            }
//        } catch let error {
//            print("Couldn't delete the realm file when asked to, reason: \(error.localizedDescription)")
//        }
//    }
//}
