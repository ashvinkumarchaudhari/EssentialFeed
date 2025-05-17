//
//  FeedItemWrapper.swift
//  EssentialFeed
//
//  Created by Ashvinkumar Chaudhari on 17.05.2025.
//
import Foundation


internal final class FeedItemWrapper
{

    private struct Root : Decodable {
        var items: [Item]
        var feed:[FeedItem]  {
            return items.map {$0.item}
        }
    }
    
 
    private struct Item : Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item:FeedItem {
            FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }
    
    static private var OK_200 : Int {
         return 200
     }
     
    internal static func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteLoader.Result {
       guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
           return .failure(.invalidateData)
       }
        return .success(root.feed)
     }
}
