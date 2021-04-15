//
//  Array+DuplicatesTests.swift
//  Copyright © 2021 Just Eat Takeaway. All rights reserved.
//

import XCTest

class Array_DuplicatesTests: XCTestCase {

    func test_noDuplicatesFound() {
        let noDuplicates = ["some", "array", "with", "no", "duplicates"]
        let expectedValue: [String] = []
        XCTAssertEqual(noDuplicates.duplicates(), expectedValue)
    }
    
    func test_duplicatesFound() {
        let noDuplicates = ["some", "array", "with", "some", "duplicates", "here", "here", "and", "here"]
        let expectedValue = ["here", "some"]
        XCTAssertEqual(noDuplicates.duplicates().sorted(), expectedValue)
    }
}
