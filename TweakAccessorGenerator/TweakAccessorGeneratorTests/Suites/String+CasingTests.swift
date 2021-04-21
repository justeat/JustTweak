//
//  String+CasingTests.swift
//  Copyright © 2021 Just Eat Takeaway. All rights reserved.
//

import XCTest

class String_CasingTests: XCTestCase {

    func test_camelCased_with_default_separator_1() {
        let sut = "Some-Property_Key_some-Value_some"
        let expectedValue = "some-PropertyKeySome-ValueSome"
        XCTAssertEqual(expectedValue, sut.camelCased())
    }
    
    func test_camelCased_with_default_separator_2() {
        let sut = "Some_PropertyKey"
        let expectedValue = "somePropertyKey"
        XCTAssertEqual(expectedValue, sut.camelCased())
    }
    
    func test_camelCased_with_custom_separator() {
        let sut = "Some-Property:Key:some-Value:Some"
        let expectedValue = "some-PropertyKeySome-ValueSome"
        XCTAssertEqual(expectedValue, sut.camelCased(with: ":"))
    }
    
    func test_lowercasedFirstChar() {
        let sut = "SomeName"
        let expectedValue = "someName"
        XCTAssertEqual(expectedValue, sut.lowercasedFirstChar())
    }
    
    func test_capitalisedFirstChar() {
        let sut = "someName"
        let expectedValue = "SomeName"
        XCTAssertEqual(expectedValue, sut.capitalisedFirstChar())
    }
}
