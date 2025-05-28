//
//  URLSessionHTTPClientTests.swift
//  EssentialFeed
//
//  Created by Ashvinkumar Chaudhari on 18.05.2025.
//

import XCTest
import EssentialFeed




class URLSessionHTTPClientTests: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        URLProtocolStub.StartInterCeptingRequest()
    }
    
    override class func tearDown() {
        super.tearDown()
        URLProtocolStub.StopInterCeptingRequest()
    }
    
    func test_GetFromUrl_ResponseDataTaskWithURL()
    {
        let url = anyURl()
        let exp = expectation(description: "wait for completion")
        URLProtocolStub.observeRequest {  request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        makeSUT().get(from: url) { _ in }
        wait(for: [exp], timeout: 1.0)
    
    }
    
    func test_getFromURL_failsOnRequestError() {
        let requestError = NSError(domain: "any error", code: 1) // anyError()
        let receiveError = resultError(error: requestError)
        XCTAssertEqual(receiveError as NSError?, requestError)
    }
    
    func test_getFromURL_AllInvalidRepresentationRequest() {
        
        XCTAssertNotNil(resultError())
        XCTAssertNotNil(resultError(response: unexpectedHttpResponse()))
//        XCTAssertNotNil(resultError(response: anyHttpResponse()))
        XCTAssertNotNil(resultError(data: anyData()))
        XCTAssertNotNil(resultError(data: anyData(), error: anyError()))
        XCTAssertNotNil(resultError(response: unexpectedHttpResponse(),error: anyError()))
        XCTAssertNotNil(resultError(response: anyHttpResponse(),error: anyError()))
        XCTAssertNotNil(resultError(data:anyData(), response: unexpectedHttpResponse(),error: anyError()))
        XCTAssertNotNil(resultError(data:anyData(), response: anyHttpResponse(),error: anyError()))
        XCTAssertNotNil(resultError(data:anyData(), response: unexpectedHttpResponse(),error: nil))
        
    }
    
    func test_getFromURL_SuceedHttpUrlData() {
        
        let data = anyData()
        let response = anyHttpResponse()
        let receivedResponse = resultValues(data: data, response: response, error: nil)
        let emptyData = Data()
        XCTAssertEqual(receivedResponse?.data, emptyData)
        XCTAssertEqual(receivedResponse?.response.statusCode, response.statusCode)
        XCTAssertEqual(receivedResponse?.response.url, response.url)
    }
    
    func test_getFromURL_SuceedWithEmptyDataHttpUrlDataNil() {
        
        let response = anyHttpResponse()
        let receivedResponse = resultValues(data: nil, response: response, error: nil)
        let emptyData = Data()
        XCTAssertEqual(receivedResponse?.data, emptyData)
        XCTAssertEqual(receivedResponse?.response.statusCode, response.statusCode)
        XCTAssertEqual(receivedResponse?.response.url, response.url)
    }
    
    private class URLProtocolStub: URLProtocol {
        private static var stubs:Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data? , response: URLResponse? , error: Error? ) {
            stubs = Stub(data: data, response: response, error: error)
        }
        
        static func observeRequest(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func StartInterCeptingRequest()
        {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func StopInterCeptingRequest()
        {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stubs = nil
            requestObserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            
            if let data = URLProtocolStub.stubs?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            if let response = URLProtocolStub.stubs?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stubs?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {
            URLProtocolStub.requestObserver = nil
            URLProtocolStub.stubs = nil
        }
        
    }
    
    // Helper
    private func makeSUT(file: StaticString = #file,line: UInt = #line) -> HttpClient {
        let sut = URLSession.shared
//        trackMemoryLeak(sut,file: file, line: line)
        return sut
    }
    
    private func resultError(data: Data? = nil, response: URLResponse? = nil, error: Error? = nil,file: StaticString = #file,line: UInt = #line) -> Error? {
        
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        switch result {
          case .failure(let error):
            return error
        default:
            XCTFail("Expected failure, got \(result) instead", file: file, line: line)
            return nil
        }

    }
    
    private func resultValues(data: Data? = nil, response: URLResponse? = nil, error: Error? = nil,file: StaticString = #file,line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
    
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        switch result {
        case .success(data, response):
            return (data, response) as? (data: Data, response: HTTPURLResponse)
        default:
            XCTFail("Expected success, got \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    private func resultFor(data: Data? = nil, response: URLResponse? = nil, error: Error? = nil,file: StaticString = #file,line: UInt = #line) -> HttpClientResult {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let exp = expectation(description: "wait for completion")
        var reciverValues: HttpClientResult!
        let sut = makeSUT(file: file, line: line)
        sut.get(from: anyURl()) { result in
            reciverValues = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return reciverValues
    }
    
    private func anyURl() -> URL {
        return URL(string: "https://any-url.com")!
    }
    
    private func anyError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
    private func unexpectedHttpResponse() -> URLResponse {
        return URLResponse(url: anyURl(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyHttpResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURl(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func anyData() -> Data {
        return Data("any data".utf8)
    }
    
}
