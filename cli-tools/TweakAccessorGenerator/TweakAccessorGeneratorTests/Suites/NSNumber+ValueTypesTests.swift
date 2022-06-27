//
//  NSNumber+ValueTypesTests.swift
//  Copyright © 2021 Just Eat Takeaway. All rights reserved.
//

import Foundation
import XCTest

class NSNumber_ValueTypesTests: XCTestCase {

    func test_tweakType_for_NSNumber_with_Int_value() {
        let sut = NSNumber(value: 42)
        XCTAssertEqual(sut.tweakType, "Int")
    }
    
    func test_tweakType_for_NSNumber_with_IntegerLiteral_value() {
        let sut2 = NSNumber(integerLiteral: 42)
        XCTAssertEqual(sut2.tweakType, "Int")
    }
    
    func test_tweakType_for_NSNumber_with_Double_value() {
        let sut = NSNumber(value: 3.14)
        XCTAssertEqual(sut.tweakType, "Double")
    }
    
    func test_tweakType_for_NSNumber_with_FloatLiteral_value() {
        let sut = NSNumber(floatLiteral: 3.14)
        XCTAssertEqual(sut.tweakType, "Double")
    }
    
    func test_tweakType_for_NSNumber_with_Bool_value() {
        let sut = NSNumber(value: true)
        XCTAssertEqual(sut.tweakType, "Bool")
    }
}
