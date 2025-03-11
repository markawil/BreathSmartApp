//
//  GithubUserViewModel.swift
//  BreathSmartCBL
//
//  Created by Mark Wilkinson on 3/9/25.
//

import Combine
import Foundation

class GithubUserViewModel: ObservableObject {
    
    @Published var user: GithubUser?
    var username: String
    
    private var cancellables: Set<AnyCancellable> = []
    private let service: GithuUserProvider?
    
    init(with service: GithuUserProvider = GithubUserService(),
         username: String) {
        self.service = service
        self.username = username
        setupSubscriber()
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
        cancellables = []
    }
    
    func setupSubscriber() {
        
        service?.userPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.user, on: self)
            .store(in: &cancellables)
        
        do {
            try service?.loadUser(from: username)
        } catch let error {
            print("Couldn't download the user from github: \(error.localizedDescription)")
        }
    }
}
