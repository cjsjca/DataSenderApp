//
//  BasicTests.swift
//  DataSenderAppTests
//

import XCTest

class BasicTests: XCTestCase {
    
    func testBasicAssertion() {
        XCTAssertEqual(2 + 2, 4)
    }
    
    func testStringEquality() {
        let greeting = "Hello, World!"
        XCTAssertEqual(greeting, "Hello, World!")
    }
}