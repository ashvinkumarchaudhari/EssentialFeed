//
//  URLSessionHTTPClientTests.swift
//  EssentialFeed
//
//  Created by Ashvinkumar Chaudhari on 18.05.2025.
//

import XCTest

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask
}

protocol HTTPSessionTask {
    func resume()
}

extension URLSession: HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask {
        return dataTask(with: url, completionHandler: completionHandler) as URLSessionDataTask
    }
}

extension URLSessionDataTask: HTTPSessionTask {}

class URLSessionHTTPClient {
    let session: HTTPSession
    
    init(session: HTTPSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: url) { _, _, _ in
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    func test_GetFromUrl_CreateDataTaskWithURL() {
        let url = URL(string: "https://www.google.com")!
        let session = HTTPSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url)
        
        XCTAssertEqual(session.receivedURLs, [url])
    }
}

class HTTPSessionSpy: HTTPSession {
    var receivedURLs = [URL]()
    
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask {
        receivedURLs.append(url)
        return FakeHTTPSessionTask()
    }
}

class FakeHTTPSessionTask: HTTPSessionTask {
    func resume() {}
}
