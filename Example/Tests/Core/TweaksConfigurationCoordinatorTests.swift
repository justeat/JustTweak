
import XCTest
import JustTweak

class TweaksConfigurationCoordinatorTests: XCTestCase {
    
    var configurationCoordinator: TweaksConfigurationsCoordinator!
    let jsonConfiguration: JSONTweaksConfiguration = {
        let bundle = Bundle(for: TweaksConfigurationCoordinatorTests.self)
        let jsonConfigurationURL = bundle.url(forResource: "test_configuration", withExtension: "json")!
        let jsonConfiguration = JSONTweaksConfiguration(jsonURL: jsonConfigurationURL)!
        return jsonConfiguration
    }()
    var userDefaultsConfiguration: UserDefaultsTweaksConfiguration!
    
    override func setUp() {
        super.setUp()
        let mockFirebaseConfiguration = MockTweaksRemoteConfiguration()
        let testUserDefaults = UserDefaults(suiteName: "com.JustTweak.Tests")!
        userDefaultsConfiguration = UserDefaultsTweaksConfiguration(userDefaults: testUserDefaults)
        let configurations: [TweaksConfiguration] = [jsonConfiguration, mockFirebaseConfiguration, userDefaultsConfiguration]
        configurationCoordinator = TweaksConfigurationsCoordinator(configurations: configurations)
    }
    
    override func tearDown() {
        userDefaultsConfiguration.deleteValue(feature: Features.UICustomization.rawValue, variable: Variables.GreetOnAppDidBecomeActive.rawValue)
        configurationCoordinator = nil
        super.tearDown()
    }
    
    func testReturnsNoMutableConfiguration_IfNoneHasBeenPassedToInitializer() {
        let configurationCoordinator = TweaksConfigurationsCoordinator(configurations: [jsonConfiguration])
        XCTAssertNil(configurationCoordinator.topCustomizableConfiguration())
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
        XCTAssertTrue(configurationCoordinator.valueForTweakWith(feature: Features.General.rawValue, variable: Variables.TapToChangeViewColor.rawValue) as! Bool)
    }
    
    func testReturnsUserSetValue_ForGreetOnAppDidBecomeActiveTweak_AfterUpdatingUserDefaultsConfiguration() {
        let mutableConfiguration = configurationCoordinator.topCustomizableConfiguration()
        mutableConfiguration?.set(false, feature: Features.UICustomization.rawValue, variable: Variables.GreetOnAppDidBecomeActive.rawValue)
        XCTAssertFalse(configurationCoordinator.valueForTweakWith(feature: Features.UICustomization.rawValue, variable: Variables.GreetOnAppDidBecomeActive.rawValue) as! Bool)
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
    let features: [String : [String]] = [:]
    let knownValues = [Variables.DisplayRedView.rawValue: ["Value": true],
                       Variables.DisplayYellowView.rawValue: ["Value": false],
                       Variables.DisplayGreenView.rawValue: ["Value": false],
                       Variables.GreetOnAppDidBecomeActive.rawValue: ["Value": true]]
    
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
