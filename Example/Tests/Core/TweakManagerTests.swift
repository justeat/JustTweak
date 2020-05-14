//
//  TweakManagerTests.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import XCTest
@testable import JustTweak

class TweakManagerTests: XCTestCase {
    
    var tweakManager: TweakManager!
    let localConfiguration: LocalConfiguration = {
        let bundle = Bundle(for: TweakManagerTests.self)
        let jsonConfigurationURL = bundle.url(forResource: "test_configuration", withExtension: "json")!
        return LocalConfiguration(jsonURL: jsonConfigurationURL)
    }()
    var userDefaultsConfiguration: UserDefaultsConfiguration!
    
    override func setUp() {
        super.setUp()
        let mockConfiguration = MockConfiguration()
        let testUserDefaults = UserDefaults(suiteName: "com.JustTweak.TweakManagerTests")!
        userDefaultsConfiguration = UserDefaultsConfiguration(userDefaults: testUserDefaults)
        let configurations: [Configuration] = [userDefaultsConfiguration, mockConfiguration, localConfiguration]
        tweakManager = TweakManager(configurations: configurations)
    }
    
    override func tearDown() {
        userDefaultsConfiguration.deleteValue(feature: Features.UICustomization, variable: Variables.GreetOnAppDidBecomeActive)
        tweakManager = nil
        super.tearDown()
    }
    
    func testReturnsNoMutableConfiguration_IfNoneHasBeenPassedToInitializer() {
        let tweakManager = TweakManager(configurations: [localConfiguration])
        XCTAssertNil(tweakManager.mutableConfiguration)
    }
    
    func testReturnsRemoteConfigValue_ForDisplayRedViewTweak() {
        XCTAssertTrue(tweakManager.tweakWith(feature: Features.UICustomization, variable: Variables.DisplayRedView)!.boolValue)
    }
    
    func testReturnsRemoteConfigValue_ForDisplayYellowViewTweak() {
        XCTAssertFalse(tweakManager.tweakWith(feature: Features.UICustomization, variable: Variables.DisplayYellowView)!.boolValue)
    }
    
    func testReturnsRemoteConfigValue_ForDisplayGreenViewTweak() {
        XCTAssertFalse(tweakManager.tweakWith(feature: Features.UICustomization, variable: Variables.DisplayGreenView)!.boolValue)
    }
    
    func testReturnsRemoteConfigValue_ForGreetOnAppDidBecomeActiveTweak() {
        XCTAssertTrue(tweakManager.tweakWith(feature: Features.UICustomization, variable: Variables.GreetOnAppDidBecomeActive)!.boolValue)
    }
    
    func testReturnsJSONConfigValue_ForTapToChangeViewColorTweak_AsYetUnkown() {
        XCTAssertTrue(tweakManager.tweakWith(feature: Features.General, variable: Variables.TapToChangeViewColor)!.boolValue)
    }
    
    func testReturnsUserSetValue_ForGreetOnAppDidBecomeActiveTweak_AfterUpdatingUserDefaultsConfiguration() {
        let mutableConfiguration = tweakManager.mutableConfiguration!
        mutableConfiguration.set(false, feature: Features.UICustomization, variable: Variables.GreetOnAppDidBecomeActive)
        XCTAssertFalse(tweakManager.tweakWith(feature: Features.UICustomization, variable: Variables.GreetOnAppDidBecomeActive)!.boolValue)
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

fileprivate class MockConfiguration: Configuration {
    
    var logClosure: LogClosure?
    let features: [String : [String]] = [:]
    let knownValues = [Variables.DisplayRedView: ["Value": true],
                       Variables.DisplayYellowView: ["Value": false],
                       Variables.DisplayGreenView: ["Value": false],
                       Variables.GreetOnAppDidBecomeActive: ["Value": true]]
    
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
