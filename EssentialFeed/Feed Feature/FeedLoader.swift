//
//  Copyright © Essential Developer. All rights reserved.
//

import Foundation

//enum LoadFeedResult<Error: Swift.Error>

enum LoadFeedResult
{
	case success([FeedItem])
	case failure(Error)
}

//extension LoadFeedResult : Equatable where Error: Equatable {}
protocol FeedLoader {
    //     associatedtype Error: Swift.Error
    //	func load(completion: @escaping (LoadFeedResult<Error>) -> Void)
    func load(completion: @escaping (LoadFeedResult) -> Void)
}



