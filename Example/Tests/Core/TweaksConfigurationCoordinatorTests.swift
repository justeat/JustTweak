
import XCTest
import JustTweak

class TweaksConfigurationCoordinatorTests: XCTestCase {
    
    var configurationCoordinator: TweaksConfigurationsCoordinator!
    let jsonConfiguration: LocalConfiguration = {
        let bundle = Bundle(for: TweaksConfigurationCoordinatorTests.self)
        let jsonConfigurationURL = bundle.url(forResource: "test_configuration", withExtension: "json")!
        let jsonConfiguration = LocalConfiguration(jsonURL: jsonConfigurationURL)!
        return jsonConfiguration
    }()
    var userDefaultsConfiguration: UserDefaultsConfiguration!
    
    override func setUp() {
        super.setUp()
        let mockFirebaseConfiguration = MockTweaksRemoteConfiguration()
        let testUserDefaults = UserDefaults(suiteName: "com.JustTweak.Tests")!
        userDefaultsConfiguration = UserDefaultsConfiguration(userDefaults: testUserDefaults)
        let configurations: [Configuration] = [jsonConfiguration, mockFirebaseConfiguration, userDefaultsConfiguration]
        configurationCoordinator = TweaksConfigurationsCoordinator(configurations: configurations)
    }
    
    override func tearDown() {
        userDefaultsConfiguration.deleteValue(feature: Features.UICustomization, variable: Variables.GreetOnAppDidBecomeActive)
        configurationCoordinator = nil
        super.tearDown()
    }
    
    func testReturnsNoMutableConfiguration_IfNoneHasBeenPassedToInitializer() {
        let configurationCoordinator = TweaksConfigurationsCoordinator(configurations: [jsonConfiguration])
        XCTAssertNil(configurationCoordinator.topCustomizableConfiguration())
    }
    
    func testReturnsNil_ForUndefinedTweak() {
        XCTAssertNil(configurationCoordinator.valueForTweakWith(feature: Features.UICustomization, variable: "some_undefined_tweak"))
    }
    
    func testReturnsRemoteConfigValue_ForDisplayRedViewTweak() {
        XCTAssertTrue(configurationCoordinator.valueForTweakWith(feature: Features.UICustomization, variable: Variables.DisplayRedView) as! Bool)
    }
    
    func testReturnsRemoteConfigValue_ForDisplayYellowViewTweak() {
        XCTAssertFalse(configurationCoordinator.valueForTweakWith(feature: Features.UICustomization, variable: Variables.DisplayYellowView) as! Bool)
    }
    
    func testReturnsRemoteConfigValue_ForDisplayGreenViewTweak() {
        XCTAssertFalse(configurationCoordinator.valueForTweakWith(feature: Features.UICustomization, variable: Variables.DisplayGreenView) as! Bool)
    }
    
    func testReturnsRemoteConfigValue_ForGreetOnAppDidBecomeActiveTweak() {
        XCTAssertTrue(configurationCoordinator.valueForTweakWith(feature: Features.UICustomization, variable: Variables.GreetOnAppDidBecomeActive) as! Bool)
    }
    
    func testReturnsJSONConfigValue_ForTapToChangeViewColorTweak_AsYetUnkown() {
        XCTAssertTrue(configurationCoordinator.valueForTweakWith(feature: Features.General, variable: Variables.TapToChangeViewColor) as! Bool)
    }
    
    func testReturnsUserSetValue_ForGreetOnAppDidBecomeActiveTweak_AfterUpdatingUserDefaultsConfiguration() {
        let mutableConfiguration = configurationCoordinator.topCustomizableConfiguration()
        mutableConfiguration?.set(false, feature: Features.UICustomization, variable: Variables.GreetOnAppDidBecomeActive)
        XCTAssertFalse(configurationCoordinator.valueForTweakWith(feature: Features.UICustomization, variable: Variables.GreetOnAppDidBecomeActive) as! Bool)
    }
    
    func testCallsClosureForRegisteredObserverWhenAnyConfigurationChanges() {
        var didCallClosure = false
        configurationCoordinator.registerForConfigurationsUpdates(self) { tweakIdentifier in
            didCallClosure = true
        }
        let tweak = Tweak(feature: "feature", variable: "variable", value: "value")
        let userInfo = [TweaksConfigurationDidChangeNotificationTweakKey: tweak]
        NotificationCenter.default.post(name: TweaksConfigurationDidChangeNotification, object: self, userInfo: userInfo)
        XCTAssertTrue(didCallClosure)
    }
    
    func testDoesNotCallClosureForDeregisteredObserverWhenAnyConfigurationChanges() {
        var didCallClosure = false
        configurationCoordinator.registerForConfigurationsUpdates(self) { tweakIdentifier in
            didCallClosure = true
        }
        configurationCoordinator.deregisterFromConfigurationsUpdates(self)
        let tweak = Tweak(feature: "feature", variable: "variable", value: "value")
        let userInfo = [TweaksConfigurationDidChangeNotificationTweakKey: tweak]
        NotificationCenter.default.post(name: TweaksConfigurationDidChangeNotification, object: self, userInfo: userInfo)
        XCTAssertFalse(didCallClosure)
    }
}

class MockTweaksRemoteConfiguration: Configuration {
    
    var logClosure: TweaksLogClosure?
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
