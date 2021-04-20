//
//  TweakManagerTests.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import XCTest
@testable import JustTweak

class TweakManagerTests: XCTestCase {
    
    var tweakManager: TweakManager!
    let localTweakProvider: TweakProvider = {
        let bundle = Bundle(for: TweakManagerTests.self)
        let jsonConfigurationURL = bundle.url(forResource: "LocalTweaks_test", withExtension: "json")!
        return LocalTweakProvider(jsonURL: jsonConfigurationURL)
    }()
    var userDefaultsTweakProvider: UserDefaultsTweakProvider!
    
    override func setUp() {
        super.setUp()
        let mockTweakProvider = MockTweakProvider()
        let testUserDefaults = UserDefaults(suiteName: "com.JustTweak.TweakManagerTests")!
        userDefaultsTweakProvider = UserDefaultsTweakProvider(userDefaults: testUserDefaults)
        let tweakProviders: [TweakProvider] = [userDefaultsTweakProvider, mockTweakProvider, localTweakProvider]
        tweakManager = TweakManager(tweakProviders: tweakProviders)
    }
    
    override func tearDown() {
        userDefaultsTweakProvider.deleteValue(feature: Features.uiCustomization, variable: Variables.greetOnAppDidBecomeActive)
        tweakManager = nil
        super.tearDown()
    }
    
    func testReturnsNoMutableTweakProvider_IfNoneHasBeenPassedToInitializer() {
        let tweakManager = TweakManager(tweakProviders: [localTweakProvider])
        XCTAssertNil(tweakManager.mutableTweakProvider)
    }
    
    func testReturnsNil_ForUndefinedTweak() {
        XCTAssertNil(tweakManager.tweakWith(feature: Features.uiCustomization, variable: "some_undefined_tweak"))
    }
    
    func testReturnsRemoteConfigValue_ForDisplayRedViewTweak() {
        XCTAssertTrue(tweakManager.tweakWith(feature: Features.uiCustomization, variable: Variables.displayRedView)!.boolValue)
    }
    
    func testReturnsRemoteConfigValue_ForDisplayYellowViewTweak() {
        XCTAssertFalse(tweakManager.tweakWith(feature: Features.uiCustomization, variable: Variables.displayYellowView)!.boolValue)
    }
    
    func testReturnsRemoteConfigValue_ForDisplayGreenViewTweak() {
        XCTAssertFalse(tweakManager.tweakWith(feature: Features.uiCustomization, variable: Variables.displayGreenView)!.boolValue)
    }
    
    func testReturnsRemoteConfigValue_ForGreetOnAppDidBecomeActiveTweak() {
        XCTAssertTrue(tweakManager.tweakWith(feature: Features.uiCustomization, variable: Variables.greetOnAppDidBecomeActive)!.boolValue)
    }
    
    func testReturnsJSONConfigValue_ForTapToChangeViewColorTweak_AsYetUnkown() {
        XCTAssertTrue(tweakManager.tweakWith(feature: Features.general, variable: Variables.tapToChangeViewColor)!.boolValue)
    }
    
    func testReturnsUserSetValue_ForGreetOnAppDidBecomeActiveTweak_AfterUpdatingUserDefaultsTweakProvider() {
        let mutableTweakProvider = tweakManager.mutableTweakProvider!
        mutableTweakProvider.set(false, feature: Features.uiCustomization, variable: Variables.greetOnAppDidBecomeActive)
        XCTAssertFalse(tweakManager.tweakWith(feature: Features.uiCustomization, variable: Variables.greetOnAppDidBecomeActive)!.boolValue)
    }
    
    func testCallsClosureForRegisteredObserverWhenAnyConfigurationChanges() {
        var didCallClosure = false
        tweakManager.registerForConfigurationsUpdates(self) { tweakIdentifier in
            didCallClosure = true
        }
        let tweak = Tweak(feature: "feature", variable: "variable", value: "value")
        let userInfo = [TweakConfigurationDidChangeNotificationTweakKey: tweak]
        NotificationCenter.default.post(name: TweakConfigurationDidChangeNotification, object: self, userInfo: userInfo)
        XCTAssertTrue(didCallClosure)
    }
    
    func testDoesNotCallClosureForDeregisteredObserverWhenAnyConfigurationChanges() {
        var didCallClosure = false
        tweakManager.registerForConfigurationsUpdates(self) { tweakIdentifier in
            didCallClosure = true
        }
        tweakManager.deregisterFromConfigurationsUpdates(self)
        let tweak = Tweak(feature: "feature", variable: "variable", value: "value")
        let userInfo = [TweakConfigurationDidChangeNotificationTweakKey: tweak]
        NotificationCenter.default.post(name: TweakConfigurationDidChangeNotification, object: self, userInfo: userInfo)
        XCTAssertFalse(didCallClosure)
    }
}

fileprivate class MockTweakProvider: TweakProvider {
    
    var logClosure: LogClosure?
    let features: [String : [String]] = [:]
    let knownValues = [Variables.displayRedView: ["Value": true],
                       Variables.displayYellowView: ["Value": false],
                       Variables.displayGreenView: ["Value": false],
                       Variables.greetOnAppDidBecomeActive: ["Value": true]]
    
    func isFeatureEnabled(_ feature: String) -> Bool {
        return false
    }
    
    func tweakWith(feature: String, variable: String) -> Tweak? {
        guard let value = knownValues[variable] else { return nil }
        return Tweak(feature: feature, variable: variable, value: value["Value"]!, title: nil, group: nil)
    }
    
    func activeVariation(for experiment: String) -> String? {
        return nil
    }
}
