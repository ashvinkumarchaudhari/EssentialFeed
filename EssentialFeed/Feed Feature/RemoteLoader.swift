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
        self.client.get(from: self.url!) { result in
            switch result {
            case let .success(data, response):
                do {
                    let items = try FeedItemWrapper.map(data, response)
                    completion(.success(items))
                }
                catch {
                    completion(.failure(.invalidateData))
                }
               
                break
            case .failure:
                completion(.failure(.connectivity))

            }
        }
    }
    
}

var OK_200 : Int {
    return 200
}

private class FeedItemWrapper
{
    struct Root : Decodable {
        var items: [Item]
    }

    struct Item : Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item:FeedItem {
            FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == OK_200 else {
            throw RemoteLoader.Error.invalidateData
        }
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.items.map {$0.item}
    }
}


