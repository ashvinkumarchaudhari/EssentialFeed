//
//  RemoteLoaderTests.swift
//  EssentialFeed
//
//  Created by Ashvinkumar Chaudhari on 11.05.2025.
//

import XCTest
@testable import EssentialFeed


class RemoteLoaderTests: XCTest {
    
    func test_init_doesnotequalRequestDataUrl()
    {
        let (_,client) = makeSUT(URL(string: "invalid url")!)
        XCTAssertTrue(client.requestURls.isEmpty)
    }
    
    func test_init_RequestDataUrl()
    {
        let url = URL(string: "https://www.google.com")!
        let (sut,client) = makeSUT(URL(string: "https://www.google.com")!)
        XCTAssertEqual(client.requestURls[0], url)
    }
    
    func test_load_RequestDataUrl()
    {
        let url = URL(string: "https://www.google.com")!
        let (_,client) = makeSUT(URL(string: "https://www.google.com")!)
        XCTAssertEqual(client.requestURls, [url,url])
    }
    
    func test_error_RequestDataUrl()
    {
        let (sut,client) = makeSUT(URL(string: "https://www.google.com")!)
        var captureError = [RemoteLoader.Error]()
        sut.load {captureError.append($0)}
        let clientError = NSError(domain: "Test", code: 0) as! Error

//        client.completions[0](clientError)
        client.complete(with: clientError, at: 0)
        XCTAssertEqual(captureError, [.connectivity])
    }
    
    private func makeSUT(_ url:URL) -> (RemoteLoader, httpClientSpy) {
       let clientSpy = httpClientSpy()
       let sut = RemoteLoader(client: clientSpy, url: url)
        return (sut, clientSpy)
    }
    
    private final class httpClientSpy: HttpClient {
        var requestURls: [URL] {
            return messages.map{ $0.url}
        }
//        var completions = [(Error) -> Void]()
        private var messages = [(url:URL, completion:(Error) -> Void)]()
        func get(from url: URL, completion: @escaping (Error) -> Void) {
        
//            self.requestURls.append(url)
//            self.completions.append(completion)
            messages.append((url,completion))
        }
        
        func complete(with error:Error, at index:Int = 0)
        {
//            completions[index](error)
            messages[index].completion(error)
        }
    }
}

