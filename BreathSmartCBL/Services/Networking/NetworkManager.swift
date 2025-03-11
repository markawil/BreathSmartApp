//
//  NetworkManager.swift
//  BreathSmartCBL
//
//  Created by Mark Wilkinson on 3/9/25.
//

import Combine
import Foundation

/*
 Helper class with methods returning Publishers for network calls.
 */
class NetworkManager {
    
    enum NetworkingError: LocalizedError {
        case badURLResponse(url: URL)
        case unknown
        
        var errorDescription: String? {
            switch self {
            case .badURLResponse(let url):
                return "[🔥] Bad URL Response: \(url)"
            case .unknown:
                return "[⚠️] Unknown Error"
            }
        }
    }
    
    static func download(from url: URL) -> AnyPublisher<Data, Error> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .subscribe(on: DispatchQueue.global(qos: .default))
            .tryMap { (output) -> Data in
                return try handle(urlResponse: output, url: url)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    static func handle(urlResponse output: URLSession.DataTaskPublisher.Output, url: URL) throws -> Data {
        guard let response = output.response as? HTTPURLResponse, response.statusCode >= 200 && response.statusCode < 300 else {
            throw NetworkingError.badURLResponse(url: url)
        }
        
        return output.data
    }
    
    static func handle(completion: Subscribers.Completion<Error>) {
        switch completion {
        case .finished:
            print("Finished")
        case .failure(let error):
            print("Error: \(error.localizedDescription)")
        }
    }
}
