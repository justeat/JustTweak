//
//  Accessor.swift
//  Copyright (c) 2019 Just Eat Holding Ltd. All rights reserved.
//

import XCTest
import JustTweak

class Accessor {
    
    static let tweakManager: TweakManager = {
        let ephemeralTweakProvider: MutableTweakProvider = NSMutableDictionary()
        return TweakManager(tweakProviders: [ephemeralTweakProvider])
    }()
    
    @FallbackTweakProperty(fallbackValue: "default",
                           feature: "stringValue_feature",
                           variable: "stringValue_variable",
                           tweakManager: tweakManager)
    var stringValue: String
    
    @FallbackTweakProperty(fallbackValue: false,
                           feature: "boolValue_feature",
                           variable: "boolValue_variable",
                           tweakManager: tweakManager)
    var boolValue: Bool
    
    @FallbackTweakProperty(fallbackValue: 42,
                           feature: "intValue_feature",
                           variable: "intValue_variable",
                           tweakManager: tweakManager)
    var intValue: Int
    
    @FallbackTweakProperty(fallbackValue: 3.14,
                           feature: "doubleValue_feature",
                           variable: "doubleValue_variable",
                           tweakManager: tweakManager)
    var doubleValue: Double
    
    @FallbackTweakProperty(fallbackValue: 108.0,
                           feature: "floatValue_feature",
                           variable: "floatValue_variable",
                           tweakManager: tweakManager)
    var floatValue: Float
    
    @OptionalTweakProperty(fallbackValue: nil,
                           feature: "optional_stringValue_feature",
                           variable: "optional_stringValue_variable",
                           tweakManager: tweakManager)
    var optionalStringValue: String?
    
    @OptionalTweakProperty(fallbackValue: nil,
                           feature: "optional_boolValue_feature",
                           variable: "optional_boolValue_variable",
                           tweakManager: tweakManager)
    var optionalBoolValue: Bool?
    
    @OptionalTweakProperty(fallbackValue: nil,
                           feature: "optional_intValue_feature",
                           variable: "optional_intValue_variable",
                           tweakManager: tweakManager)
    var optionalIntValue: Int?
    
    @OptionalTweakProperty(fallbackValue: nil,
                           feature: "optional_doubleValue_feature",
                           variable: "optional_doubleValue_variable",
                           tweakManager: tweakManager)
    var optionalDoubleValue: Double?
    
    @OptionalTweakProperty(fallbackValue: nil,
                           feature: "optional_floatValue_feature",
                           variable: "optional_floatValue_variable",
                           tweakManager: tweakManager)
    var optionalFloatValue: Float?
}

class FeatureFlagPropertyWrapperTests: XCTestCase {
    
    var accessor: Accessor!
    
    override func setUp() {
        accessor = Accessor()
    }
    
    override func tearDown() {
        accessor = nil
    }
    
    func test_StringFeatureFlag() {
        XCTAssertEqual(accessor.stringValue, "default")
        let newValue = "other value"
        accessor.stringValue = newValue
        XCTAssertEqual(accessor.stringValue, newValue)
    }
    
    func test_BoolFeatureFlag() {
        XCTAssertFalse(accessor.boolValue)
        accessor.boolValue = true
        XCTAssertTrue(accessor.boolValue)
    }
    
    func test_IntFeatureFlag() {
        XCTAssertEqual(accessor.intValue, 42)
        let newValue = 100
        accessor.intValue = newValue
        XCTAssertEqual(accessor.intValue, newValue)
    }
    
    func test_DoubleFeatureFlag() {
        XCTAssertEqual(accessor.doubleValue, 3.14)
        let newValue = 100.200
        accessor.doubleValue = newValue
        XCTAssertEqual(accessor.doubleValue, newValue)
    }
    
    func test_FloatFeatureFlag() {
        XCTAssertEqual(accessor.floatValue, 108.0)
        let newValue: Float = 100.200
        accessor.floatValue = newValue
        XCTAssertEqual(accessor.floatValue, newValue)
    }
    
    func test_OptionalStringFeatureFlag() {
        XCTAssertEqual(accessor.optionalStringValue, nil)
        let newValue = "some value"
        accessor.optionalStringValue = newValue
        XCTAssertEqual(accessor.optionalStringValue, newValue)
    }
    
    func test_OptionalBoolFeatureFlag() {
        XCTAssertEqual(accessor.optionalBoolValue, nil)
        accessor.optionalBoolValue = true
        XCTAssertEqual(accessor.optionalBoolValue, true)
    }
    
    func test_OptionalIntFeatureFlag() {
        XCTAssertEqual(accessor.optionalIntValue, nil)
        let newValue = 100
        accessor.optionalIntValue = newValue
        XCTAssertEqual(accessor.optionalIntValue, newValue)
    }
    
    func test_OptionalDoubleFeatureFlag() {
        XCTAssertEqual(accessor.optionalDoubleValue, nil)
        let newValue = 3.14
        accessor.optionalDoubleValue = newValue
        XCTAssertEqual(accessor.optionalDoubleValue, newValue)
    }
    
    func test_OptionalFloatFeatureFlag() {
        XCTAssertEqual(accessor.optionalFloatValue, nil)
        let newValue: Float = 108.0
        accessor.optionalFloatValue = newValue
        XCTAssertEqual(accessor.optionalFloatValue, newValue)
    }
}
