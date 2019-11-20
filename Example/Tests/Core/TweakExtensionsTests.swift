//
//  TweakExtensionsTests.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import XCTest
import JustTweak

class TweakExtensionsTests: XCTestCase {
    
    func testString_RepresentingBool_CanBeConvertedToTweakValue_True() {
        XCTAssertTrue("true".tweakValue.boolValue)
    }
    
    func testString_RepresentingBool_CanBeConvertedToTweakValue_False() {
        XCTAssertFalse("false".tweakValue.boolValue)
    }
    
    func testString_RepresentingBool_CanBeConvertedToTweakValue_MixedCaseTrue() {
        XCTAssertTrue("TrUe".tweakValue.boolValue)
    }
    
    func testString_RepresentingBool_CanBeConvertedToTweakValue_MixedCaseFalse() {
        XCTAssertFalse("fAlSe".tweakValue.boolValue)
    }
    
    func testString_RepresentingNumber_CanBeConvertedToTweakValue_Double() {
        XCTAssertTrue("1.0".tweakValue == 1.0)
    }
    
    func testString_RepresentingNumber_CanBeConvertedToTweakValue_Int() {
        XCTAssertTrue("1".tweakValue == 1)
    }
    
    func testString_ReturnsSelfAsTweakValue_IfDoesNotRepresentAnyOtherTypeOfTweakValue() {
        XCTAssertTrue("hello".tweakValue == "hello")
    }
    
    func testIntValueCanBeConvertedIntoNumber() {
        let value: Int = 1
        let tweakValue: TweakValue = value
        XCTAssertEqual(NSNumber(value: value), NSNumber(tweakValue: tweakValue))
    }
    
    func testFloatValueCanBeConvertedIntoNumber() {
        let value: Float = 1
        let tweakValue: TweakValue = value
        XCTAssertEqual(NSNumber(value: value), NSNumber(tweakValue: tweakValue))
    }
    
    func testDoubleValueCanBeConvertedIntoNumber() {
        let value: Double = 1
        let tweakValue: TweakValue = value
        XCTAssertEqual(NSNumber(value: value), NSNumber(tweakValue: tweakValue))
    }
    
    func testBoolValueCanBeConvertedIntoNumber() {
        let value = true
        let tweakValue: TweakValue = value
        XCTAssertEqual(NSNumber(value: value), NSNumber(tweakValue: tweakValue))
    }
    
    func testStringValueCannotBeConvertedIntoNumber() {
        let tweakValue: TweakValue = "Hello"
        XCTAssertNil(NSNumber(tweakValue: tweakValue))
    }
    
    func testNumberCanBeConvertedIntoBoolTweak() {
        let tweakValue: TweakValue = true
        XCTAssertTrue(NSNumber(value: true).tweakValue == tweakValue)
        XCTAssertTrue(NSNumber(value: false).tweakValue == false)
    }
    
    func testNumberCanBeConvertedIntoIntTweak() {
        XCTAssertTrue(NSNumber(value: 1).tweakValue == 1)
    }
}
