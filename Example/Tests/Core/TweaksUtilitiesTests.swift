//
//  TweaksUtilitiesTests.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import XCTest
import JustTweak

class TweaksUtilitiesTests: XCTestCase {
    
    func testExclusiveBinaryOperator_ReturnsFirstArgument_WhenFirstArgumentIsNotNil() {
        XCTAssertEqual("a" ?! "b", "a")
    }
    
    func testExclusiveBinaryOperator_ReturnsSecondArgument_WhenFirstArgumentIsNil() {
        XCTAssertEqual(nil ?! "b", "b")
    }
    
    func testExclusiveBinaryOperator_ReturnsTrue_WhenFirstArgumentIsNilAndSecondIsTrue() {
        XCTAssertTrue(nil ?! true)
    }

    func testExclusiveBinaryOperator_ReturnsFalse_WhenFirstArgumentIsFalseAndSecondIsTrue() {
        XCTAssertFalse(false ?! true)
    }
    
    func testExclusiveBinaryOperator_ReturnsNil_WhenBothArgumentsAreNil() {
        let a: String? = nil
        let b: String? = nil
        XCTAssertNil(a ?! b)
    }
    
    func testInclusingOrForBooleansOperator_ReturnsFalse_WhenFirstArgumentIsFalseAndSecondIsFalse() {
        XCTAssertFalse(false ||| false)
    }
    
    func testInclusingOrForBooleansOperator_ReturnsTrue_WhenFirstArgumentIsTrueAndSecondIsTrue() {
        XCTAssertTrue(true ||| true)
    }
    
    func testInclusingOrForBooleansOperator_ReturnsTrue_WhenFirstArgumentIsFalseAndSecondIsTrue() {
        XCTAssertTrue(false ||| true)
    }
    
    func testInclusingOrForBooleansOperator_ReturnsTrue_WhenFirstArgumentIsTrueAndSecondIsFalse() {
        XCTAssertTrue(true ||| false)
    }
    
    func testInclusingOrForBooleansOperator_ReturnsTrue_WhenFirstArgumentIsNilAndSecondIsTrue() {
        XCTAssertTrue(nil ||| true)
    }
    
    func testInclusingOrForBooleansOperator_ReturnsTrue_WhenFirstArgumentIsTrueAndSecondIsNil() {
        XCTAssertTrue(true ||| nil)
    }
    
    func testInclusingOrForBooleansOperator_ReturnsFalse_WhenFirstArgumentIsNilAndSecondIsFalse() {
        XCTAssertFalse(nil ||| false)
    }
    
    func testInclusingOrForBooleansOperator_ReturnsFalse_WhenFirstArgumentIsFalseAndSecondIsNil() {
        XCTAssertFalse(false ||| nil)
    }
    
    func testInclusingOrForBooleansOperator_ReturnsFalse_WhenBothArgumentsAreNil() {
        XCTAssertFalse(nil ||| nil)
    }
    
}
