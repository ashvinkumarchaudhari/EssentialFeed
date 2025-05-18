//
//  RemoteLoader.swift
//  EssentialFeed
//
//  Created by Ashvinkumar Chaudhari on 11.05.2025.
//

import Foundation


public final class RemoteLoader:FeedLoader {
    let client:HttpClient
    let url:URL?
//    public enum Error:Swift.Error {
    public enum Error : Swift.Error {
        case connectivity
        case invalidateData
    }
    
//   typealias Result = LoadFeedResult<Error>
    typealias Result = LoadFeedResult

     init(client: HttpClient, url: URL? ) {
        self.client = client
        self.url = url
    }
    
     func load(completion: @escaping (Result) -> Void)
    {
        self.client.get(from: self.url!) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success(data, response):
                completion(FeedItemWrapper.map(data, response))
                break
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    
}




