//
//  TweakManagerCacheTests.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import XCTest
@testable import JustTweak

fileprivate struct Constants {
    static let featureActiveValue = true
    static let feature = "some_feature"
    static let variable = "some_variable"
    static let experiment = "some_experiment"
    static let activeVariation = "some_experiment_variation"
}

class TweakManagerCacheTests: XCTestCase {
    
    fileprivate var mockConfiguration: MockConfiguration!
    var tweakManager: TweakManager!

    override func setUp() {
        super.setUp()
        mockConfiguration = MockConfiguration()
        tweakManager = TweakManager(configurations: [mockConfiguration])
        tweakManager.useCache = true
    }
    
    override func tearDown() {
        mockConfiguration = nil
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
        XCTAssertEqual(mockConfiguration.isFeatureEnabledCallsCounter, 0)
        XCTAssertEqual(tweakManager.isFeatureEnabled(Constants.feature), Constants.featureActiveValue)
        XCTAssertEqual(mockConfiguration.isFeatureEnabledCallsCounter, 1)
        XCTAssertEqual(tweakManager.isFeatureEnabled(Constants.feature), Constants.featureActiveValue)
        XCTAssertEqual(mockConfiguration.isFeatureEnabledCallsCounter, useCache ? 1 : 2)
        tweakManager.resetCache()
        XCTAssertEqual(tweakManager.isFeatureEnabled(Constants.feature), Constants.featureActiveValue)
        XCTAssertEqual(mockConfiguration.isFeatureEnabledCallsCounter, useCache ? 2 : 3)
    }
    
    // MARK: - tweakWith(feature:variable:)
    
    func testTweakFetch_CacheDisabled() {
        tweakFetch(useCache: false)
    }
    
    func testTweakFetch_CacheEnabled() {
        tweakFetch(useCache: true)
    }
    
    private func tweakFetch(useCache: Bool) {
        tweakManager.useCache = useCache
        XCTAssertEqual(mockConfiguration.tweakWithFeatureVariableCallsCounter, 0)
        let value = true
        tweakManager.set(value, feature: Constants.feature, variable: Constants.variable)
        XCTAssertEqual(tweakManager.tweakWith(feature: Constants.feature, variable: Constants.variable)!.value as! Bool, value)
        XCTAssertEqual(mockConfiguration.tweakWithFeatureVariableCallsCounter, 1)
        XCTAssertEqual(tweakManager.tweakWith(feature: Constants.feature, variable: Constants.variable)!.value as! Bool, value)
        XCTAssertEqual(mockConfiguration.tweakWithFeatureVariableCallsCounter, useCache ? 1 : 2)
        tweakManager.set(value, feature: Constants.feature, variable: Constants.variable)
        XCTAssertEqual(tweakManager.tweakWith(feature: Constants.feature, variable: Constants.variable)!.value as! Bool, value)
        XCTAssertEqual(mockConfiguration.tweakWithFeatureVariableCallsCounter, useCache ? 2 : 3)
        tweakManager.resetCache()
        XCTAssertEqual(tweakManager.tweakWith(feature: Constants.feature, variable: Constants.variable)!.value as! Bool, value)
        XCTAssertEqual(mockConfiguration.tweakWithFeatureVariableCallsCounter, useCache ? 3 : 4)
    }
    
    // MARK: - activeVariation(experiment:)
    
    func testActiveVariation_CacheDisabled() {
        testActiveVariation(useCache: false)
    }
    
    func testActiveVariation_CacheEnabled() {
        testActiveVariation(useCache: true)
    }
    
    private func testActiveVariation(useCache: Bool) {
        tweakManager.useCache = useCache
        XCTAssertEqual(mockConfiguration.activeVariationCallsCounter, 0)
        XCTAssertEqual(tweakManager.activeVariation(for: Constants.experiment), Constants.activeVariation)
        XCTAssertEqual(mockConfiguration.activeVariationCallsCounter, 1)
        XCTAssertEqual(tweakManager.activeVariation(for: Constants.experiment), Constants.activeVariation)
        XCTAssertEqual(mockConfiguration.activeVariationCallsCounter, useCache ? 1 : 2)
        tweakManager.resetCache()
        XCTAssertEqual(tweakManager.activeVariation(for: Constants.experiment), Constants.activeVariation)
        XCTAssertEqual(mockConfiguration.activeVariationCallsCounter, useCache ? 2 : 3)
    }
}

fileprivate class MockConfiguration: MutableConfiguration {
    
    var logClosure: LogClosure?
    
    var isFeatureEnabledCallsCounter: Int = 0
    var tweakWithFeatureVariableCallsCounter: Int = 0
    var activeVariationCallsCounter: Int = 0
    
    var featureBackingStore: [String : Bool] = [Constants.feature: Constants.featureActiveValue]
    var tweakBackingStore: [String : [String : Tweak]] = [:]
    var experimentBackingStore: [String : String] = [Constants.experiment: Constants.activeVariation]
    
    func isFeatureEnabled(_ feature: String) -> Bool {
        isFeatureEnabledCallsCounter += 1
        return featureBackingStore[feature] ?? false
    }
    
    func tweakWith(feature: String, variable: String) -> Tweak? {
        tweakWithFeatureVariableCallsCounter += 1
        return tweakBackingStore[feature]?[variable]
    }
    
    func activeVariation(for experiment: String) -> String? {
        activeVariationCallsCounter += 1
        return experimentBackingStore[experiment]
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
