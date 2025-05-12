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
        XCTAssertEqual(client.requestURl, url)
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
        var captureError:Error?
        sut.load { error in
            captureError = error
        }
        client.complete(with: captureError!)
        
        XCTAssertEqual(captureError, .connectivity)
    }
    
    private func makeSUT(_ url:URL) -> (RemoteLoader, httpClientSpy) {
       let clientSpy = httpClientSpy()
       let sut = RemoteLoader(client: clientSpy, url: url)
        return (sut, clientSpy)
    }
    
    private final class httpClientSpy: HttpClient {
        var requestURl: URL?
        var requestURls: [URL] = []
        var completions = [(Error) -> Void]()
        func get(from url: URL, completion: @escaping (Error) -> Void) {
            self.requestURl = url
            self.requestURls.append(url)
            self.completions.append(completion)
        }
        
        func complete(with error:Error, at index:Int = 0)
        {
            completions[index](error)
        }
    }
}

