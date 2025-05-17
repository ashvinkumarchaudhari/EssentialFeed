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
    
    
    func complete(withStatusCode:Int, data:Data , at index:Int = 0)
    {
        let httpRes = HTTPURLResponse(url: requestURls[index], statusCode: withStatusCode, httpVersion: nil, headerFields: nil)!
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
        expect(sut, result: .failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0) as Error
            client.complete(with: clientError)
        }
    }
    
    func test_error_200RequestDataUrl()
    {
        let (sut,client) = makeSUT(URL(string: "https://www.google.com")!)
        // let clientError = NSError(domain: "Test", code: 0) as! Error
        let sample = [199,201,300,400,500]
        sample.enumerated().forEach { index, value in
            expect(sut, result: .failure(.invalidateData)) {
                let json = makeItemJson(item: [])
                client.complete(withStatusCode: value, data: json, at: index)
            }
        }
    }
    
    func test_error_200WithInvalidJsonRequestDataUrl()
    {
        let (sut,client) = makeSUT(URL(string: "https://www.google.com")!)
        expect(sut, result: .failure(.invalidateData)) {
            let invalidJson = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJson)
        }
        
    }
    
    func test_error_200WithEmptyJsonRequestDataUrl()
    {
        let (sut,client) = makeSUT(URL(string: "https://www.google.com")!)
        expect(sut, result:.success([])) {
            let validEmptyJson = makeItemJson(item: [])
            client.complete(withStatusCode: 200, data: validEmptyJson)
        }
    }
    
    func test_error_200WithJsonRequestDataUrl()
    {
        let (sut,client) = makeSUT(URL(string: "https://www.google.com")!)
        let (modal1,json1) = makeItem(id: UUID(), description: "description", location: "location", imageURL: URL(string: "https://www.google.com")!)
        let (modal2,json2) = makeItem(id: UUID(), imageURL: URL(string: "https://www.google.com")!)
        
        expect(sut, result: .success([modal1,modal2])) {
            let validJson = makeItemJson(item: [json1,json2])
            client.complete(withStatusCode: 200, data: validJson)
        }
        
    }
    
    func test_sut_deallocated_when_client_complete()
    {
        let clientSpy = httpClientSpy()
        var sut:RemoteLoader? = RemoteLoader(client: clientSpy, url: URL(string: "https://www.google.com")!)
        var captureResult = [RemoteLoader.Result]()
        sut?.load { result in
            captureResult.append(result)
        }
        sut = nil
        clientSpy.complete(withStatusCode: 200, data: makeItemJson(item: []))
        XCTAssertTrue(captureResult.isEmpty)
    }
    
    // Helpers
    private func makeSUT(_ url:URL, file: StaticString = #file, line: UInt = #line) -> (RemoteLoader, httpClientSpy) {
        let clientSpy = httpClientSpy()
        let sut = RemoteLoader(client: clientSpy, url: url)
        trackMemoryLeak(sut)
        trackMemoryLeak(clientSpy)
        return (sut, clientSpy)
    }
    
    private func trackMemoryLeak(_ instance: AnyObject?, file: StaticString = #file, line: UInt = #line)
    {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "instance should not deallocated" ,file: file, line: line)
        }
    }
    
    private func expect(_ sut: RemoteLoader,result:RemoteLoader.Result, action:() -> Void, file: StaticString = #file, line: UInt = #line)
    {
        var captureResult = [RemoteLoader.Result]()
        //        sut.load {captureError.append($0)}
        sut.load { result in
            captureResult.append(result)
            
        }
        action()
        XCTAssertEqual(captureResult, [result], file: file, line: line)
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model:FeedItem, json: [String: Any]) {
        let feedItem = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
//        let feedJson = ["id": id.uuidString,
//                        "description": description,
//                        "location": location,
//                        "image": imageURL.absoluteString].reduce(into: [String:Any]()) { (acc, e) in
//            if let value = e.value {
//                acc[e.key] = value
//            }
//        }
        let feedJson = ["id": id.uuidString,
                        "description": description,
                        "location": location,
                        "image": imageURL.absoluteString].compactMapValues { $0 }
        return (feedItem, feedJson)
    }
    
    private func makeItemJson(item:[[String: Any]]) -> Data
    {
        let json = ["items":item]
        let validJson = try! JSONSerialization.data(withJSONObject: json)
        return validJson
    }
    
    
    
}

