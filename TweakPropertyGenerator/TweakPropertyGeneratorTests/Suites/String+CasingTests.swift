//
//  String+CasingTests.swift
//  Copyright © 2021 Just Eat Takeaway. All rights reserved.
//

import XCTest

class String_CasingTests: XCTestCase {

    func test_camelCased_with_default_separator() {
        let sut = "Some-Property_Key_1-Value_1"
        let expectedValue = "some-propertyKey1-Value1"
        XCTAssertEqual(expectedValue, sut.camelCased())
    }
    
    func test_camelCased_with_custom_separator() {
        let sut = "Some-Property:Key:1-Value:1"
        let expectedValue = "some-propertyKey1-Value1"
        XCTAssertEqual(expectedValue, sut.camelCased(with: ":"))
    }
    
    func test_lowercaseFirstChar() {
        let sut = "SomeName"
        let expectedValue = "someName"
        XCTAssertEqual(expectedValue, sut.lowercaseFirstChar())
    }
}
