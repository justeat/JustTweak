//
//  UserDefaultsTweakProviderTests.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import XCTest
import JustTweak

class UserDefaultsTweakProviderTests: XCTestCase {
    
    private var userDefaultsTweakProvider: UserDefaultsTweakProvider!
    private let userDefaults = UserDefaults(suiteName: String(describing: UserDefaultsTweakProviderTests.self))!

    private let userDefaultsKeyPrefix = "lib.fragments.userDefaultsKey"

    override func setUp() {
        super.setUp()
        userDefaultsTweakProvider = UserDefaultsTweakProvider(userDefaults: userDefaults)
    }
    
    override func tearDown() {
        userDefaults.removeObject(forKey: "\(userDefaultsKeyPrefix).display_red_view")
        userDefaultsTweakProvider = nil
        super.tearDown()
    }
    
    func testReturnsCorrectTweaksIdentifiersWhenInitializedAndTweaksHaveBeenSet() {
        let anotherConfiguration = UserDefaultsTweakProvider(userDefaults: userDefaults)
        anotherConfiguration.set("hello", feature: "feature_1", variable: "variable_4")
        anotherConfiguration.set(true, feature: "feature_1", variable: "variable_3")
        anotherConfiguration.set(12.34, feature: "feature_1", variable: "variable_2")
        anotherConfiguration.set(42, feature: "feature_1", variable: "variable_1")
        
        XCTAssertTrue(anotherConfiguration.tweakWith(feature: "feature_1", variable: "variable_1")!.value == 42)
        XCTAssertTrue(anotherConfiguration.tweakWith(feature: "feature_1", variable: "variable_2")!.value == 12.34)
        XCTAssertTrue(anotherConfiguration.tweakWith(feature: "feature_1", variable: "variable_3")!.value == true)
        XCTAssertTrue(anotherConfiguration.tweakWith(feature: "feature_1", variable: "variable_4")!.value == "hello")
    }
    
    func testReturnsNilForTweaksThatHaveNoUserDefaultValue() {
        let tweak = userDefaultsTweakProvider.tweakWith(feature: Features.uiCustomization, variable: Variables.displayRedView)
        XCTAssertNil(tweak)
    }
    
    func testUpdatesValueForTweak_withBool() {
        userDefaultsTweakProvider.set(true, feature: "feature_1", variable: "variable_1")
        let tweak = userDefaultsTweakProvider.tweakWith(feature: "feature_1", variable: "variable_1")
        XCTAssertTrue(tweak!.value == true)
    }
    
    func testUpdatesValueForTweak_withInteger() {
        userDefaultsTweakProvider.set(42, feature: "feature_1", variable: "variable_1")
        let tweak = userDefaultsTweakProvider.tweakWith(feature: "feature_1", variable: "variable_1")
        XCTAssertTrue(tweak!.value == 42)
    }
    
    func testUpdatesValueForTweak_withFloat() {
        userDefaultsTweakProvider.set(Float(12.34), feature: "feature_1", variable: "variable_1")
        let tweak = userDefaultsTweakProvider.tweakWith(feature: "feature_1", variable: "variable_1")
        XCTAssertTrue(tweak!.value == Float(12.34))
    }
    
    func testUpdatesValueForTweak_withDouble() {
        userDefaultsTweakProvider.set(Double(23.45), feature: "feature_1", variable: "variable_1")
        let tweak = userDefaultsTweakProvider.tweakWith(feature: "feature_1", variable: "variable_1")
        XCTAssertTrue(tweak!.value == Double(23.45))
    }
    
    func testUpdatesValueForTweak_withString() {
        userDefaultsTweakProvider.set("Hello", feature: "feature_1", variable: "variable_1")
        let tweak = userDefaultsTweakProvider.tweakWith(feature: "feature_1", variable: "variable_1")
        XCTAssertTrue(tweak!.value == "Hello")
    }
    
    func testDecryptionClosure() {
        XCTAssertNil(userDefaultsTweakProvider.decryptionClosure)
        
        userDefaultsTweakProvider.decryptionClosure = { tweak in
            (tweak.value.stringValue ?? "") + "Decrypted"
        }
        
        let tweak = Tweak(feature: "feature", variable: "variable", value: "topSecret")
        let decryptedTweak = userDefaultsTweakProvider.decryptionClosure?(tweak)
        
        XCTAssertEqual(decryptedTweak?.stringValue, "topSecretDecrypted")
    }
}
