//
//  RemoteLoader.swift
//  EssentialFeed
//
//  Created by Ashvinkumar Chaudhari on 11.05.2025.
//

import Foundation


class RemoteLoader {
    let client:HttpClient
    let url:URL?
    enum Error:Swift.Error {
        case connectivity
        case invalidateData
    }
    
    enum Result : Equatable {
        case success([FeedItem])
        case failure(Error)
    }
 
    init(client: HttpClient, url: URL? ) {
        self.client = client
        self.url = url
    }
    
    func load(_ completion: @escaping (Result) -> Void)
    {
        self.client.get(from: self.url!) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success(data, response):
                completion(FeedItemWrapper.map(data, response))
                break
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
    
    
}




