//
//  RemoteLoaderTests.swift
//  EssentialFeed
//
//  Created by Ashvinkumar Chaudhari on 11.05.2025.
//

import XCTest
@testable import EssentialFeed

private final class httpClientSpy: HttpClient {
    //        var completions = [(Error) -> Void]()
    private var messages = [(url:URL, completion:(HttpClientResult) -> Void)]()
    var requestURls: [URL] {
        return messages.map{ $0.url}
    }
    func get(from url: URL, completion: @escaping (HttpClientResult) -> Void) {
        
        //            self.requestURls.append(url)
        //            self.completions.append(completion)
        messages.append((url,completion))
    }
    
    func complete(with error:Error, at index:Int = 0)
    {
        //            completions[index](error)
        messages[index].completion(.failure(error))
    }
    

    func complete(withStatusCode:Int, data:Data = Data(), at index:Int = 0)
    {
        let httpRes = HTTPURLResponse(url: URL(string: "https://www.google.com")!, statusCode: withStatusCode, httpVersion: nil, headerFields: nil)!
        messages[index].completion(.success(data, httpRes))
    }
}

class RemoteLoaderTests: XCTestCase {
    
    func test_init_doesnotequalRequestDataUrl()
    {
        let (_,client) = makeSUT(URL(string: "invalid url")!)
        XCTAssertTrue(client.requestURls.isEmpty)
    }
    
    func test_init_RequestDataUrl()
    {
        let url = URL(string: "https://www.google.com")!
        let (_,client) = makeSUT(URL(string: "https://www.google.com")!)
        XCTAssertEqual(client.requestURls, [])
    }
    
    func test_load_RequestDataUrl()
    {
        let url = URL(string: "https://www.google.com")!
        let (sut,client) = makeSUT(URL(string: "https://www.google.com")!)
        sut.load {_ in }
        XCTAssertEqual(client.requestURls, [url])
    }
    
    func test_error_RequestDataUrl()
    {
        let (sut,client) = makeSUT(URL(string: "https://www.google.com")!)
        var captureError = [RemoteLoader.Error]()
        sut.load {captureError.append($0)}
        let clientError = NSError(domain: "Test", code: 0) as Error
        
        //        client.completions[0](clientError)
        client.complete(with: clientError, at: 0)
        XCTAssertEqual(captureError, [.connectivity])
    }
    
    func test_error_200RequestDataUrl()
    {
        let (sut,client) = makeSUT(URL(string: "https://www.google.com")!)
        // let clientError = NSError(domain: "Test", code: 0) as! Error
        let sample = [200,105,300,400,500]
        sample.enumerated().forEach { index, value in
            var captureError = [RemoteLoader.Error]()
            sut.load {captureError.append($0)}
            //        client.completions[0](clientError)
            client.complete(withStatusCode: value, at: index)
            XCTAssertEqual(captureError, [.invalidateData])
        }
    }
    
    func test_error_200WithInvalidJsonRequestDataUrl()
    {
        let (sut,client) = makeSUT(URL(string: "https://www.google.com")!)
        //        let clientError = NSError(domain: "Test", code: 0) as! Error
//        var captureError = [RemoteLoader.Error]()
//        sut.load {captureError.append($0)}
        expect(sut, error: .invalidateData) {
            //        client.completions[0](clientError)
            let invalidJson = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJson)
        }

    }
    
    // Helpers
    
    private func makeSUT(_ url:URL) -> (RemoteLoader, httpClientSpy) {
        let clientSpy = httpClientSpy()
        let sut = RemoteLoader(client: clientSpy, url: url)
        return (sut, clientSpy)
    }
    
    private func expect(_ sut: RemoteLoader,error:RemoteLoader.Error, action:() -> Void, file: StaticString = #file, line: UInt = #line)
    {
        var captureError = [RemoteLoader.Error]()
        sut.load {captureError.append($0)}
        action()
        XCTAssertEqual(captureError, [error], file: file, line: line)
    }
    
}

