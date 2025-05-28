//
//  Untitled.swift
//  EssentialFeed
//
//  Created by tejas on 28/05/25.
//
import XCTest

//class TrackMemoryLeak: XCTestCase {
//
//}

//extension XCTestCase {
//
//    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
//        addTeardownBlock { [weak instance] in
//            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
//        }
//    }
//    
//}


extension XCTestCase {
    /// Tracks and asserts that `instance` is deallocated after the test finishes.
    func trackMemoryLeak(_ instance: AnyObject,file: StaticString = #file,line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance,"Instance should have been deallocated. Potential memory leak.",file: file,line: line)
        }
    }
}
