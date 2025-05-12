//
//  RemoteLoader.swift
//  EssentialFeed
//
//  Created by Ashvinkumar Chaudhari on 11.05.2025.
//

import Foundation

enum Error:Swift.Error {
    case connectivity
}

class RemoteLoader {
    let client:HttpClient
    let url:URL?
    
    init(client: HttpClient, url: URL? ) {
        self.client = client
        self.url = url
    }
    
    func load(_ completion: @escaping (Error) -> Void)
    {
        self.client.get(from: self.url!) { error in
            completion(.connectivity)
        }
    }
    
}

protocol HttpClient {
    func get(from _url : URL, completion: @escaping (Error) -> Void)
}
