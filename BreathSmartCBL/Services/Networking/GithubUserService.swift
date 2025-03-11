//
//  GithubUserService.swift
//  BreathSmartCBL
//
//  Created by Mark Wilkinson on 3/9/25.
//

import Combine
import Foundation

/*
 Service that provides a github user's basic information
 */
protocol GithuUserProvider {
    
    var userPublisher: AnyPublisher<GithubUser?, Never> { get }
    func loadUser(from username: String) throws
}

class GithubUserService: GithuUserProvider {
    
    private(set) var userSubject = CurrentValueSubject<GithubUser?, Never>(nil)
    
    var userPublisher: AnyPublisher<GithubUser?, Never> {
        userSubject
            .share()
            .eraseToAnyPublisher()
    }
        
    private var userSubscription: AnyCancellable?
    
    func loadUser(from username: String) throws {
        let urlString = "https://api.github.com/users/\(username)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            throw URLError(.badURL)
        }
                
        userSubscription = NetworkManager.download(from: url)
            .decode(type: GithubUser.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { (completion) in
                NetworkManager.handle(completion: completion)
            }, receiveValue: { [weak self] user in
                self?.userSubject.send(user)
                self?.userSubscription?.cancel()
            })
    }

}
