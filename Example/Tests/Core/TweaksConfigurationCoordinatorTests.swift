
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
            @objc let priority: TweaksConfigurationPriority = .p10
            @objc var allTweakIdentifiers: [String] { get { return [] } }
            
            @objc func isFeatureEnabled(_ feature: String) -> Bool { return false }
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
        XCTAssertNil(configurationCoordinator.valueForTweakWith(feature: Features.UICustomization.rawValue, variable: "some_undefined_tweak"))
    }
    
    func testReturnsRemoteConfigValue_ForDisplayRedViewTweak() {
        XCTAssertTrue(configurationCoordinator.valueForTweakWith(feature: Features.UICustomization.rawValue, variable: Variables.DisplayRedView.rawValue) as! Bool)
    }
    
    func testReturnsRemoteConfigValue_ForDisplayYellowViewTweak() {
        XCTAssertFalse(configurationCoordinator.valueForTweakWith(feature: Features.UICustomization.rawValue, variable: Variables.DisplayYellowView.rawValue) as! Bool)
    }
    
    func testReturnsRemoteConfigValue_ForDisplayGreenViewTweak() {
        XCTAssertFalse(configurationCoordinator.valueForTweakWith(feature: Features.UICustomization.rawValue, variable: Variables.DisplayGreenView.rawValue) as! Bool)
    }
    
    func testReturnsRemoteConfigValue_ForGreetOnAppDidBecomeActiveTweak() {
        XCTAssertTrue(configurationCoordinator.valueForTweakWith(feature: Features.UICustomization.rawValue, variable: Variables.GreetOnAppDidBecomeActive.rawValue) as! Bool)
    }
    
    func testReturnsJSONConfigValue_ForTapToChangeViewColorTweak_AsYetUnkown() {
        XCTAssertTrue(configurationCoordinator.valueForTweakWith(feature: Features.UICustomization.rawValue, variable: Variables.TapToChangeViewColor.rawValue) as! Bool)
    }
    
    func testReturnsUserSetValue_ForGreetOnAppDidBecomeActiveTweak_AfterUpdatingUserDefaultsConfiguration() {
        let mutableConfiguration = configurationCoordinator.topCustomizableConfiguration()
        mutableConfiguration?.set(value: false, forTweakWithIdentifier: Variables.GreetOnAppDidBecomeActive.rawValue)
        XCTAssertFalse(configurationCoordinator.valueForTweakWith(feature: Features.UICustomization.rawValue, variable: Variables.GreetOnAppDidBecomeActive.rawValue) as! Bool)
    }
    
    func testReturnsAllDisplayableValues_ForValuesInJSONConfig_AsDisplayable_WithExpectedTitle_WithValueByConfigPriority() {
        let redViewTweak = Tweak(identifier: Variables.DisplayRedView.rawValue, title: "Display Red View", group: "UI", value: true, canBeDisplayed: true)
        let yellowViewTweak = Tweak(identifier: Variables.DisplayYellowView.rawValue, title: "Display Yellow View", group: "UI", value: false, canBeDisplayed: true)
        let greetingsTweak = Tweak(identifier: Variables.GreetOnAppDidBecomeActive.rawValue, title: "Greet on app launch", group: "General", value: true, canBeDisplayed: true)
        let tapColorTweak = Tweak(identifier: Variables.TapToChangeViewColor.rawValue, title: nil, group: nil, value: true, canBeDisplayed: true)
        let redViewAlphaTweak = Tweak(identifier: Variables.RedViewAlpha.rawValue, title: "Red View Alpha Component", group: "UI", value: 1.0, canBeDisplayed: true)
        let buttonTitleTweak = Tweak(identifier: Variables.ChangeConfigurationButton.rawValue, title: "Change Tweaks Button Label Text", group: "UI", value: "Change Configuration", canBeDisplayed: true)
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
    let priority: TweaksConfigurationPriority = .p5
    let knownValues = ["display_red_view": ["Value": true],
                       "display_yellow_view": ["Value": false],
                       "display_green_view": ["Value": false],
                       "greet_on_app_did_become_active": ["Value": true]]
    
    func isFeatureEnabled(_ feature: String) -> Bool {
        return tweakWith(feature: "", variable: feature)?.boolValue ?? false
    }
    
    func tweakWith(feature: String, variable: String) -> Tweak? {
        guard let value = knownValues[variable] else { return nil }
        return Tweak(identifier: variable, title: nil, group: nil, value: value["Value"]!, canBeDisplayed: false)
    }
    
}
