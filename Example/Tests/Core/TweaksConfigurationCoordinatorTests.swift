
import XCTest
import JustTweak

class TweaksConfigurationCoordinatorTests: XCTestCase {
    
    var configurationCoordinator: TweaksConfigurationsCoordinator!
    let jsonConfiguration: JSONTweaksConfiguration = {
        let bundle = Bundle(for: TweaksConfigurationCoordinatorTests.self)
        let jsonConfigurationURL = bundle.url(forResource: "test_configuration", withExtension: "json")!
        let jsonConfiguration = JSONTweaksConfiguration(defaultValuesFromJSONAtURL: jsonConfigurationURL)!
        return jsonConfiguration
    }()
    var userDefaultsConfiguration: UserDefaultsTweaksConfiguration!
    
    override func setUp() {
        super.setUp()
        // Priority 1 => User Defaults Configuration
        // Priority 2 => Mock Remote Configuration
        // Priority 3 => JSON Configuration
        let mockFirebaseConfiguration = MockTweaksRemoteConfiguration()
        let testUserDefaults = UserDefaults(suiteName: "com.JustTweak.Tests")!
        userDefaultsConfiguration = UserDefaultsTweaksConfiguration(userDefaults: testUserDefaults,
                                                                    fallbackConfiguration: jsonConfiguration)
        let configurations: [TweaksConfiguration] = [mockFirebaseConfiguration, jsonConfiguration, userDefaultsConfiguration]
        configurationCoordinator = TweaksConfigurationsCoordinator(configurations: configurations)
    }
    
    override func tearDown() {
        userDefaultsConfiguration.deleteValue(forTweakWithIdentifier: "greet_on_app_did_become_active")
        configurationCoordinator = nil
        super.tearDown()
    }
    
    func testNilInitialized_WhenPassingEmptyArrayOfConfigurations() {
        XCTAssertNil(TweaksConfigurationsCoordinator(configurations: []))
    }
    
    func testReturnsNoMutableConfiguration_IfNoneHasBeenPassedToInitializer() {
        let configurationCoordinator = TweaksConfigurationsCoordinator(configurations: [jsonConfiguration])
        XCTAssertNil(configurationCoordinator?.topCustomizableConfiguration())
    }
    
    func testReturnsConsistentMutableConfiguration_IfInitializedWithMultipleMutableConfigurations_WithSamePriority() {
        @objc class MockMutableTweaksConfiguration: NSObject, MutableTweaksConfiguration {
            var logClosure: TweaksLogClosure?
            @objc let priority: TweaksConfigurationPriority = .high
            @objc var allTweakIdentifiers: [String] { get { return [] } }
            
            @objc func tweakWith(feature: String) -> Tweak? { return nil }
            @objc func tweakWith(feature: String, variable: String) -> Tweak? { return nil }
            @objc func set(boolValue value: Bool, forTweakWithIdentifier identifier: String) {}
            @objc func set(stringValue value: String, forTweakWithIdentifier identifier: String) {}
            @objc func set(numberValue value: NSNumber, forTweakWithIdentifier identifier: String) {}
            @objc func deleteValue(forTweakWithIdentifier identifier: String) {}
        }
        let configurations: [TweaksConfiguration] = [MockMutableTweaksConfiguration(),
                                                     MockMutableTweaksConfiguration(),
                                                     MockMutableTweaksConfiguration()]
        configurationCoordinator = TweaksConfigurationsCoordinator(configurations: configurations)
        let expectedConfiguration = configurationCoordinator.topCustomizableConfiguration()
        XCTAssertTrue(expectedConfiguration === configurationCoordinator.topCustomizableConfiguration())
    }
    
    func testReturnsNil_ForUndefinedTweak() {
        XCTAssertNil(configurationCoordinator.valueForTweakWith(feature: "some_undefined_tweak"))
    }
    
    func testReturnsRemoteConfigValue_ForDisplayRedViewTweak() {
        XCTAssertTrue(configurationCoordinator.valueForTweakWith(feature: "display_red_view") as! Bool)
    }
    
    func testReturnsRemoteConfigValue_ForDisplayYellowViewTweak() {
        XCTAssertFalse(configurationCoordinator.valueForTweakWith(feature: "display_yellow_view") as! Bool)
    }
    
    func testReturnsRemoteConfigValue_ForDisplayGreenViewTweak() {
        XCTAssertFalse(configurationCoordinator.valueForTweakWith(feature: "display_green_view") as! Bool)
    }
    
    func testReturnsRemoteConfigValue_ForGreetOnAppDidBecomeActiveTweak() {
        XCTAssertTrue(configurationCoordinator.valueForTweakWith(feature: "greet_on_app_did_become_active") as! Bool)
    }
    
    func testReturnsJSONConfigValue_ForTapToChangeViewColorTweak_AsYetUnkown() {
        XCTAssertTrue(configurationCoordinator.valueForTweakWith(feature: "tap_to_change_color_enabled") as! Bool)
    }
    
    func testReturnsUserSetValue_ForGreetOnAppDidBecomeActiveTweak_AfterUpdatingUserDefaultsConfiguration() {
        let mutableConfiguration = configurationCoordinator.topCustomizableConfiguration()
        mutableConfiguration?.set(value: false, forTweakWithIdentifier: "greet_on_app_did_become_active")
        XCTAssertFalse(configurationCoordinator.valueForTweakWith(feature: "greet_on_app_did_become_active") as! Bool)
    }
    
    func testReturnsAllDisplayableValues_ForValuesInJSONConfig_AsDisplayable_WithExpectedTitle_WithValueByConfigPriority() {
        let redViewTweak = Tweak(identifier: "display_red_view", title: "Display Red View", group: "UI", value: true, canBeDisplayed: true)
        let yellowViewTweak = Tweak(identifier: "display_yellow_view", title: "Display Yellow View", group: "UI", value: false, canBeDisplayed: true)
        let greetingsTweak = Tweak(identifier: "greet_on_app_did_become_active", title: "Greet on app launch", group: "General", value: true, canBeDisplayed: true)
        let tapColorTweak = Tweak(identifier: "tap_to_change_color_enabled", title: nil, group: nil, value: true, canBeDisplayed: true)
        let redViewAlphaTweak = Tweak(identifier: "red_view_alpha_component", title: "Red View Alpha Component", group: "UI", value: 1.0, canBeDisplayed: true)
        let buttonTitleTweak = Tweak(identifier: "change_tweaks_button_label_text", title: "Change Tweaks Button Label Text", group: "UI", value: "Change Configuration", canBeDisplayed: true)
        let expectedTweaks = [
            redViewTweak,
            yellowViewTweak,
            greetingsTweak,
            tapColorTweak,
            redViewAlphaTweak,
            buttonTitleTweak
        ].sorted { (lhs, rhs) -> Bool in
            return lhs.identifier < rhs.identifier
        }
        let actualTweaks = configurationCoordinator.displayableTweaks().sorted { (lhs, rhs) -> Bool in
            return lhs.identifier < rhs.identifier
        }
        XCTAssertEqual(expectedTweaks, actualTweaks)
    }
    
    func testCallsClosureForRegisteredObserverWhenAnyConfigurationChanges() {
        var didCallClosure = false
        configurationCoordinator.registerForConfigurationsUpdates(self) {
            didCallClosure = true
        }
        NotificationCenter.default.post(name: TweaksConfigurationDidChangeNotification, object: nil)
        XCTAssertTrue(didCallClosure)
    }
    
    func testDoesNotCallClosureForDeregisteredObserverWhenAnyConfigurationChanges() {
        var didCallClosure = false
        configurationCoordinator.registerForConfigurationsUpdates(self) {
            didCallClosure = true
        }
        configurationCoordinator.deregisterFromConfigurationsUpdates(self)
        NotificationCenter.default.post(name: TweaksConfigurationDidChangeNotification, object: nil)
        XCTAssertFalse(didCallClosure)
    }
    
}

class MockTweaksRemoteConfiguration: NSObject, TweaksConfiguration {

    var logClosure: TweaksLogClosure?
    let priority: TweaksConfigurationPriority = .medium
    let knownValues = ["display_red_view": ["Value": true],
                       "display_yellow_view": ["Value": false],
                       "display_green_view": ["Value": false],
                       "greet_on_app_did_become_active": ["Value": true]]
    
    func tweakWith(feature: String) -> Tweak? {
        return tweakWith(feature: "", variable: feature)
    }
    
    func tweakWith(feature: String, variable: String) -> Tweak? {
        guard let value = knownValues[variable] else { return nil }
        return Tweak(identifier: variable, title: nil, group: nil, value: value["Value"]!, canBeDisplayed: false)
    }
    
}
