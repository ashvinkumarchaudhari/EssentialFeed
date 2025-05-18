//
//  HttpClient.swift
//  EssentialFeed
//
//  Created by Ashvinkumar Chaudhari on 17.05.2025.
//

import Foundation

 enum HttpClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}
 protocol HttpClient {
    func get(from _url : URL, completion: @escaping (HttpClientResult) -> Void)
}
