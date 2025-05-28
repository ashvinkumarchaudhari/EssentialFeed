//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Ashvinkumar Chaudhari on 28.05.2025.
//
import Foundation

extension URLSession: HttpClient
{
    private struct UnexpectedError: Error {
        
    }
    public func get(from url: URL, completion: @escaping(HttpClientResult) -> Void) {
//        let url = URL(string: "https://wrong-url.com")!
            dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            }
            else if let response = response as? HTTPURLResponse,let data = data {
                completion(.success(data, response))
            }
            else {
                completion(.failure(UnexpectedError()))
            }
        }.resume()
    }
}

