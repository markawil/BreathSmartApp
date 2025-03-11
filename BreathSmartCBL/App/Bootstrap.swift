//
//  Bootstrap.swift
//  BreathSmartCBL
//
//  Created by Mark Wilkinson on 3/9/25.
//

import Foundation

class Bootstrap {
    
    let resolver = DependencyResolver.shared
    
    func registerDependencies() {
        
        let bleManager = BLEManager()
        let githubService = GithubUserService()
        
        resolver.register(instance: bleManager as BLEProvider)
        resolver.register(instance: githubService as GithuUserProvider)
    }
}
