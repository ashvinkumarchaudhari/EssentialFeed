//
//  RemoteLoader.swift
//  EssentialFeed
//
//  Created by Ashvinkumar Chaudhari on 11.05.2025.
//

import Foundation


public final class RemoteLoader: FeedLoader {
    private let client: HttpClient
    private let url: URL?
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidateData
    }
    
    public typealias Result = LoadFeedResult
    
    public init(client: HttpClient, url: URL?) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url!) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success(data, response):
                completion(FeedItemWrapper.map(data, response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}



