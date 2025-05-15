//
//  RemoteLoader.swift
//  EssentialFeed
//
//  Created by Ashvinkumar Chaudhari on 11.05.2025.
//

import Foundation

enum HttpClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}
protocol HttpClient {
    func get(from _url : URL, completion: @escaping (HttpClientResult) -> Void)
}

class RemoteLoader {
    let client:HttpClient
    let url:URL?
    enum Error:Swift.Error {
        case connectivity
        case invalidateData
    }
 
    init(client: HttpClient, url: URL? ) {
        self.client = client
        self.url = url
    }
    
    func load(_ completion: @escaping (Error) -> Void)
    {
        self.client.get(from: self.url!) { result in
            switch result {
            case .success:
                completion(.invalidateData)
                break
            case .failure:
                completion(.connectivity)

            }
        }
    }
    
}


