//
//  TweakManagerCacheTests.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import XCTest
@testable import JustTweak
@testable import JustTweak_Example

fileprivate struct Constants {
    static let featureActiveValue = true
    static let feature = "some_feature"
    static let variable = "some_variable"
    static let experiment = "some_experiment"
}

class TweakManagerCacheTests: XCTestCase {
    
    fileprivate var mockTweakProvider: MockTweakProvider!
    var tweakManager: TweakManager!

    override func setUp() {
        super.setUp()
        mockTweakProvider = MockTweakProvider()
        tweakManager = TweakManager(tweakProviders: [mockTweakProvider])
        tweakManager.useCache = true
    }
    
    override func tearDown() {
        mockTweakProvider = nil
        tweakManager = nil
        super.tearDown()
    }
    
    // MARK: - isFeatureEnabled(feature:)
    
    func testFeatureEnabled_CacheDisabled() {
        testFeatureEnabled(useCache: false)
    }
    
    func testFeatureEnabled_CacheEnabled() {
        testFeatureEnabled(useCache: true)
    }
    
    private func testFeatureEnabled(useCache: Bool) {
        tweakManager.useCache = useCache
        XCTAssertEqual(mockTweakProvider.isFeatureEnabledCallsCounter, 0)
        XCTAssertEqual(tweakManager.isFeatureEnabled(Constants.feature), Constants.featureActiveValue)
        XCTAssertEqual(mockTweakProvider.isFeatureEnabledCallsCounter, 1)
        XCTAssertEqual(tweakManager.isFeatureEnabled(Constants.feature), Constants.featureActiveValue)
        XCTAssertEqual(mockTweakProvider.isFeatureEnabledCallsCounter, useCache ? 1 : 2)
        tweakManager.resetCache()
        XCTAssertEqual(tweakManager.isFeatureEnabled(Constants.feature), Constants.featureActiveValue)
        XCTAssertEqual(mockTweakProvider.isFeatureEnabledCallsCounter, useCache ? 2 : 3)
    }
    
    // MARK: - tweakWith(feature:variable:)
    
    func testTweakFetch_CacheDisabled() throws {
        try tweakFetch(useCache: false)
    }
    
    func testTweakFetch_CacheEnabled() throws {
        try tweakFetch(useCache: true)
    }
    
    private func tweakFetch(useCache: Bool) throws {
        tweakManager.useCache = useCache
        XCTAssertEqual(mockTweakProvider.tweakWithFeatureVariableCallsCounter, 0)
        let value = true
        tweakManager.set(value, feature: Constants.feature, variable: Constants.variable)
        XCTAssertEqual(try XCTUnwrap(tweakManager.tweakWith(feature: Constants.feature, variable: Constants.variable)).value as! Bool, value)
        XCTAssertEqual(mockTweakProvider.tweakWithFeatureVariableCallsCounter, 1)
        XCTAssertEqual(try XCTUnwrap(tweakManager.tweakWith(feature: Constants.feature, variable: Constants.variable)).value as! Bool, value)
        XCTAssertEqual(mockTweakProvider.tweakWithFeatureVariableCallsCounter, useCache ? 1 : 2)
        tweakManager.set(value, feature: Constants.feature, variable: Constants.variable)
        XCTAssertEqual(try XCTUnwrap(tweakManager.tweakWith(feature: Constants.feature, variable: Constants.variable)).value as! Bool, value)
        XCTAssertEqual(mockTweakProvider.tweakWithFeatureVariableCallsCounter, useCache ? 2 : 3)
        tweakManager.resetCache()
        XCTAssertEqual(try XCTUnwrap(tweakManager.tweakWith(feature: Constants.feature, variable: Constants.variable)).value as! Bool, value)
        XCTAssertEqual(mockTweakProvider.tweakWithFeatureVariableCallsCounter, useCache ? 3 : 4)
    }
}

fileprivate class MockTweakProvider: MutableTweakProvider {
    
    var decryptionClosure: ((Tweak) -> TweakValue)?
    var logClosure: LogClosure?
    
    var isFeatureEnabledCallsCounter: Int = 0
    var tweakWithFeatureVariableCallsCounter: Int = 0
    
    var featureBackingStore: [String : Bool] = [Constants.feature: Constants.featureActiveValue]
    var tweakBackingStore: [String : [String : Tweak]] = [:]
    
    func isFeatureEnabled(_ feature: String) -> Bool {
        isFeatureEnabledCallsCounter += 1
        return featureBackingStore[feature] ?? false
    }
    
    func tweakWith(feature: String, variable: String) throws -> Tweak {
        tweakWithFeatureVariableCallsCounter += 1
        guard let tweak = tweakBackingStore[feature]?[variable] else {
            throw TweakError.notFound
        }
        return tweak
    }
    
    func set(_ value: TweakValue, feature: String, variable: String) {
        let tweak = Tweak(feature: feature, variable: variable, value: value)
        if let _ = tweakBackingStore[feature] {
            tweakBackingStore[feature]?[variable] = tweak
        }
        else {
            tweakBackingStore[feature] = [variable : tweak]
        }
    }
    
    func deleteValue(feature: String, variable: String) {
        tweakBackingStore[feature]?[variable] = nil
    }
}
