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
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    func get(from url: URL, completion: @escaping(HttpClientResult) -> Void) {
        urlSession.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
        
    func test_GetFromUrl_ErrorDataTaskWithURL()
    {
        URLProtocolStub.StartInterCeptingRequest()
        let url = URL(string: "https://www.google.com")!
        let error = NSError(domain: "test", code: 0)
        URLProtocolStub.stub(url: url, data: nil,response: nil, error: error)
        let sut = URLSessionHTTPClient()
        let exp = expectation(description: "wait for completion")
        
        sut.get(from: url) { result in
            
            switch result {
            case .failure(let error as NSError):
                XCTAssertEqual(error, error)
            default:
                XCTFail("Expected Failure with error: \(error)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        URLProtocolStub.StopInterCeptingRequest()
    }
    
    private class URLProtocolStub: URLProtocol {
        private static var stubs = [URL: Stub]()
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(url: URL, data: Data? , response: URLResponse? , error: Error? ) {
            
            stubs[url] = Stub(data: data, response: response, error: error)
        }
        
        static func StartInterCeptingRequest()
        {
            URLProtocol.registerClass(URLProtocolStub.self)

        }
        static func StopInterCeptingRequest()
        {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stubs=[:]
        }
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else { return false }
            return URLProtocolStub.stubs[url] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let url = request.url ,let stub = URLProtocolStub.stubs[url] else {
                return
            }
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)

        }
        
        override func stopLoading() {
            
        }
    
    }

    
}



