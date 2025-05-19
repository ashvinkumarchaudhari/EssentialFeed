//
//  URLSessionHTTPClientTests.swift
//  EssentialFeed
//
//  Created by Ashvinkumar Chaudhari on 18.05.2025.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient
{
   private let urlSession: URLSession
    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }
    func get(from url: URL, completion: (HttpClientResult) -> Void) {
        urlSession.dataTask(with: url) { _, _, _ in
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_GetFromUrl_ResumeDataTaskWithURL()
    {
        let url = URL(string: "https://www.google.com")!
        let urlSession = UrlSessionSpy()
        let task = URLSessionDataTaskSpy()
        urlSession.stub(url: url, task: task)
        let sut = URLSessionHTTPClient(urlSession: urlSession)
        sut.get(from: url) { _ in
            
        }
        XCTAssertEqual(task.resumeCount, 1)
    }
    
    func test_GetFromUrl_ErrorDataTaskWithURL()
    {
        let url = URL(string: "https://www.google.com")!
        let error = NSError(domain: "test", code: 0)
        let urlSession = UrlSessionSpy()
        let task = URLSessionDataTaskSpy()
        urlSession.stub(url: url, task: task)
        let sut = URLSessionHTTPClient(urlSession: urlSession)
        sut.get(from: url)
        XCTAssertEqual(task.resumeCount, 1)
    }
    
    private class UrlSessionSpy: URLSession {
        private var stubs = [URL: Stub]()
        private struct Stub {
            let task: URLSessionDataTask
            let error: Error?
        }
        
        func stub(url: URL, task: URLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
            
            stubs[url] = Stub(task: task, error: error)
        }
    
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask {
            guard let stub = stubs[url] else {
                fatalError("No stub for URL: \(url)")
            }
            completionHandler(nil, nil, stub.error)
            return stub.task
        }
    }

    private class FakeURLSessionDataTask: URLSessionDataTask
    {
       override func resume()
            {
                // do nothing
            }
    }

    private class URLSessionDataTaskSpy: URLSessionDataTask
    {
        var resumeCount = 0

        override func resume() {
            resumeCount += 1
        }
    }
    
}



