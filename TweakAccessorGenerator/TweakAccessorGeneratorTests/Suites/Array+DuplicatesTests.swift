//
//  Array+DuplicatesTests.swift
//  Copyright © 2021 Just Eat Takeaway. All rights reserved.
//

import XCTest

class Array_DuplicatesTests: XCTestCase {

    func test_noDuplicatesFound() {
        let arrayWithNoDuplicates = ["some", "array", "with", "no", "duplicates"]
        let expectedValue: [String] = []
        XCTAssertEqual(arrayWithNoDuplicates.duplicates, expectedValue)
    }
    
    func test_duplicatesFound() {
        let arrayWithDuplicates = ["some", "array", "with", "some", "duplicates", "here", "here", "and", "here"]
        let expectedValue = ["here", "some"]
        XCTAssertEqual(arrayWithDuplicates.duplicates.sorted(), expectedValue)
    }
}
