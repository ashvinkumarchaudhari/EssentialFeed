//
//  EssentialFeedApiEndTests.swift
//  EssentialFeedApiEndTests
//
//  Created by Ashvinkumar Chaudhari on 31.05.2025.
//

import XCTest
import EssentialFeed

final class EssentialFeedApiEndTests: XCTestCase {

    func test_endToEndtestServerGETFeedResult_matchesFixedAccountData(file: StaticString = #file,line: UInt = #line)  {
        
        switch getFeedResult() {
        case .success(let feed):
            XCTAssertEqual(feed.count, 8, "Expected 8 items in the feed")
//            feed.enumerated().forEach { index, item in
//                XCTAssertEqual(item, expectedItem(at: index),"unexpected item at index \(index)")
//            }
            XCTAssertEqual(feed[0], expectedItem(at: 0))
            XCTAssertEqual(feed[1], expectedItem(at: 1))
            XCTAssertEqual(feed[2], expectedItem(at: 2))
            XCTAssertEqual(feed[3], expectedItem(at: 3))
            XCTAssertEqual(feed[4], expectedItem(at: 4))
            XCTAssertEqual(feed[5], expectedItem(at: 5))
            XCTAssertEqual(feed[6], expectedItem(at: 6))
            XCTAssertEqual(feed[7], expectedItem(at: 7))

          
        case .failure(let error):
            XCTFail("Expected successful feed result, got \(error) instead")
            
        default:
            XCTFail("Expected successful feed result, got no result instead")
        }
    }
    
    // MARK: - Helpers

    private func getFeedResult(file: StaticString = #file,line: UInt = #line) -> LoadFeedResult? {
        let testServerUrl = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let client = URLSessionHTTPClient()
        let loader = RemoteLoader(client: client, url: testServerUrl)
        trackMemoryLeak(client,file: file,line: line)
        trackMemoryLeak(loader,file: file,line: line)
        let exp = expectation(description: "wait for completion")
        var receivedResult: LoadFeedResult?
        
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        return receivedResult
    }
    private func expectedItem(at index: Int) -> FeedItem {
        return FeedItem(
            id: id(at: index),
            description: description(at: index),
            location: location(at: index),
            imageURL: imageURL(at: index)
        )
    }

    private func id(at index: Int) -> UUID {
        let uuids = [
            "73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6",
            "BA298A85-6275-48D3-8315-9C8F7C1CD109",
            "5A0D45B3-8E26-4385-8C5D-213E160A5E3C",
            "FF0ECFE2-2879-403F-8DBE-A83B4010B340",
            "DC97EF5E-2CC9-4905-A8AD-3C351C311001",
            "557D87F1-25D3-4D77-82E9-364B2ED9CB30",
            "A83284EF-C2DF-415D-AB73-2A9B8B04950B",
            "F79BD7F8-063F-46E2-8147-A67635C3BB01"
        ]
        return UUID(uuidString: uuids[index])!
    }

    private func description(at index: Int) -> String? {
        let descriptions = [
            "Description 1",
            "Description 2",
            "Description 3",
            "Description 4",
            "Description 5",
            "Description 6",
            "Description 7",
            "Description 8"
        ]
        return descriptions[index]
    }

    private func location(at index: Int) -> String? {
        let locations = [
            "Location 1",
            "Location 2",
            "Location 3",
            "Location 4",
            "Location 5",
            "Location 6",
            "Location 7",
            "Location 8"
        ]
        return locations[index]
    }

    private func imageURL(at index: Int) -> URL {
        let imageURLs = [
            "https://url-1.com",
            "https://url-2.com",
            "https://url-3.com",
            "https://url-4.com",
            "https://url-5.com",
            "https://url-6.com",
            "https://url-7.com",
            "https://url-8.com"
        ]
        return URL(string: imageURLs[index])!
    }
}
