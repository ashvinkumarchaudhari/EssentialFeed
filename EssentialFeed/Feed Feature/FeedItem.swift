//
//  Copyright © Essential Developer. All rights reserved.
//

import Foundation

public struct FeedItem : Equatable {
	let id: UUID
	let description: String?
	let location: String?
	let imageURL: URL
    public init(id: UUID, description: String?, location: String?, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}

extension FeedItem : Decodable {
 private enum CodingKeys: String, CodingKey {
        case id
        case description
        case location
        case imageURL = "image"
    }
//    public init(from decoder: Decoder) throws {
//         let container = try decoder.container(keyedBy: CodingKeys.self)
//         self.id = try container.decode(UUID.self, forKey: .id)
//         self.description = try container.decodeIfPresent(String.self, forKey: .description)
//         self.location = try container.decodeIfPresent(String.self, forKey: .location)
//         self.imageURL = try container.decode(URL.self, forKey: .imageURL)
//     }
}
    
