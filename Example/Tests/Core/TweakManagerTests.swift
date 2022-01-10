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
        XCTAssertNil(try? tweakManager.tweakWith(feature: Features.uiCustomization, variable: "some_undefined_tweak"))
    }
    
    func testReturnsRemoteConfigValue_ForDisplayRedViewTweak() throws {
        XCTAssertTrue(try XCTUnwrap(tweakManager.tweakWith(feature: Features.uiCustomization, variable: Variables.displayRedView)).boolValue)
    }
    
    func testReturnsRemoteConfigValue_ForDisplayYellowViewTweak() throws {
        XCTAssertFalse(try XCTUnwrap(tweakManager.tweakWith(feature: Features.uiCustomization, variable: Variables.displayYellowView)).boolValue)
    }
    
    func testReturnsRemoteConfigValue_ForDisplayGreenViewTweak() throws {
        XCTAssertFalse(try XCTUnwrap(tweakManager.tweakWith(feature: Features.uiCustomization, variable: Variables.displayGreenView)).boolValue)
    }
    
    func testReturnsRemoteConfigValue_ForGreetOnAppDidBecomeActiveTweak() throws {
        XCTAssertTrue(try XCTUnwrap(tweakManager.tweakWith(feature: Features.uiCustomization, variable: Variables.greetOnAppDidBecomeActive)).boolValue)
    }
    
    func testReturnsJSONConfigValue_ForTapToChangeViewColorTweak_AsYetUnkown() throws {
        XCTAssertTrue(try XCTUnwrap(tweakManager.tweakWith(feature: Features.general, variable: Variables.tapToChangeViewColor)).boolValue)
    }
    
    func testReturnsUserSetValue_ForGreetOnAppDidBecomeActiveTweak_AfterUpdatingUserDefaultsTweakProvider() throws {
        let mutableTweakProvider = tweakManager.mutableTweakProvider!
        mutableTweakProvider.set(false, feature: Features.uiCustomization, variable: Variables.greetOnAppDidBecomeActive)
        XCTAssertFalse(try XCTUnwrap(tweakManager.tweakWith(feature: Features.uiCustomization, variable: Variables.greetOnAppDidBecomeActive)).boolValue)
    }
    
    func testCallsClosureForRegisteredObserverWhenAnyConfigurationChanges() {
        var didCallClosure = false
        tweakManager.registerForConfigurationsUpdates(self) { tweakIdentifier in
            didCallClosure = true
        }
        let tweak = Tweak(feature: "feature", variable: "variable", value: "value")
        let userInfo = [TweakProviderDidChangeNotificationTweakKey: tweak]
        NotificationCenter.default.post(name: TweakProviderDidChangeNotification, object: self, userInfo: userInfo)
        XCTAssertTrue(didCallClosure)
    }
    
    func testDoesNotCallClosureForDeregisteredObserverWhenAnyConfigurationChanges() {
        var didCallClosure = false
        tweakManager.registerForConfigurationsUpdates(self) { tweakIdentifier in
            didCallClosure = true
        }
        tweakManager.deregisterFromConfigurationsUpdates(self)
        let tweak = Tweak(feature: "feature", variable: "variable", value: "value")
        let userInfo = [TweakProviderDidChangeNotificationTweakKey: tweak]
        NotificationCenter.default.post(name: TweakProviderDidChangeNotification, object: self, userInfo: userInfo)
        XCTAssertFalse(didCallClosure)
    }
    
    func testTweakManagerDecryption() throws {
        let url = try XCTUnwrap(Bundle.main.url(forResource: "LocalTweaks_example", withExtension: "json"))
        
        tweakManager.tweakProviders.append(LocalTweakProvider(jsonURL: url))
        
        tweakManager.decryptionClosure = { tweak in
            String((tweak.value.stringValue ?? "").reversed())
        }
        
        let feature = "general"
        let variable = "encrypted_answer_to_the_universe"
        let tweak = try? tweakManager.tweakWith(feature: feature, variable: variable)
        
        XCTAssertEqual("Definitely not 42", tweak?.stringValue)
    }
    
    func testSetTweakManagerDecryptionClosureThenDecryptionClosureIsSetForProviders() throws {
        let mutableTweakProvider = try XCTUnwrap(tweakManager.mutableTweakProvider)
        
        XCTAssertNil(mutableTweakProvider.decryptionClosure)
        
        tweakManager.decryptionClosure = { tweak in
            tweak.value
        }
        
        XCTAssertNotNil(mutableTweakProvider.decryptionClosure)
    }
}

fileprivate class MockTweakProvider: TweakProvider {
    
    var logClosure: LogClosure?
    var decryptionClosure: ((Tweak) -> TweakValue)?
    let features: [String : [String]] = [:]
    let knownValues = [Variables.displayRedView: ["Value": true],
                       Variables.displayYellowView: ["Value": false],
                       Variables.displayGreenView: ["Value": false],
                       Variables.greetOnAppDidBecomeActive: ["Value": true]]
    
    func isFeatureEnabled(_ feature: String) -> Bool {
        return false
    }
    
    func tweakWith(feature: String, variable: String) throws -> Tweak {
        guard let value = knownValues[variable] else { throw TweakError.notFound }
        return Tweak(feature: feature, variable: variable, value: value["Value"]!, title: nil, group: nil)
    }
}
