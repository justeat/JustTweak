
import XCTest
@testable import JustTweak

class TweaksConfigurationCoordinatorTests: XCTestCase {
    
    var coordinator: JustTweak!
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
        coordinator = JustTweak(configurations: configurations)
    }
    
    override func tearDown() {
        userDefaultsConfiguration.deleteValue(feature: Features.UICustomization, variable: Variables.GreetOnAppDidBecomeActive)
        coordinator = nil
        super.tearDown()
    }
    
    func testReturnsNoMutableConfiguration_IfNoneHasBeenPassedToInitializer() {
        let coordinator = JustTweak(configurations: [jsonConfiguration])
        XCTAssertNil(coordinator.mutableConfiguration)
    }
    
    func testReturnsNil_ForUndefinedTweak() {
        XCTAssertNil(coordinator.tweakWith(feature: Features.UICustomization, variable: "some_undefined_tweak"))
    }
    
    func testReturnsRemoteConfigValue_ForDisplayRedViewTweak() {
        XCTAssertTrue(coordinator.tweakWith(feature: Features.UICustomization, variable: Variables.DisplayRedView)!.boolValue)
    }
    
    func testReturnsRemoteConfigValue_ForDisplayYellowViewTweak() {
        XCTAssertFalse(coordinator.tweakWith(feature: Features.UICustomization, variable: Variables.DisplayYellowView)!.boolValue)
    }
    
    func testReturnsRemoteConfigValue_ForDisplayGreenViewTweak() {
        XCTAssertFalse(coordinator.tweakWith(feature: Features.UICustomization, variable: Variables.DisplayGreenView)!.boolValue)
    }
    
    func testReturnsRemoteConfigValue_ForGreetOnAppDidBecomeActiveTweak() {
        XCTAssertTrue(coordinator.tweakWith(feature: Features.UICustomization, variable: Variables.GreetOnAppDidBecomeActive)!.boolValue)
    }
    
    func testReturnsJSONConfigValue_ForTapToChangeViewColorTweak_AsYetUnkown() {
        XCTAssertTrue(coordinator.tweakWith(feature: Features.General, variable: Variables.TapToChangeViewColor)!.boolValue)
    }
    
    func testReturnsUserSetValue_ForGreetOnAppDidBecomeActiveTweak_AfterUpdatingUserDefaultsConfiguration() {
        let mutableConfiguration = coordinator.mutableConfiguration
        mutableConfiguration?.set(false, feature: Features.UICustomization, variable: Variables.GreetOnAppDidBecomeActive)
        XCTAssertFalse(coordinator.tweakWith(feature: Features.UICustomization, variable: Variables.GreetOnAppDidBecomeActive)!.boolValue)
    }
    
    func testCallsClosureForRegisteredObserverWhenAnyConfigurationChanges() {
        var didCallClosure = false
        coordinator.registerForConfigurationsUpdates(self) { tweakIdentifier in
            didCallClosure = true
        }
        let tweak = Tweak(feature: "feature", variable: "variable", value: "value")
        let userInfo = [TweaksConfigurationDidChangeNotificationTweakKey: tweak]
        NotificationCenter.default.post(name: TweaksConfigurationDidChangeNotification, object: self, userInfo: userInfo)
        XCTAssertTrue(didCallClosure)
    }
    
    func testDoesNotCallClosureForDeregisteredObserverWhenAnyConfigurationChanges() {
        var didCallClosure = false
        coordinator.registerForConfigurationsUpdates(self) { tweakIdentifier in
            didCallClosure = true
        }
        coordinator.deregisterFromConfigurationsUpdates(self)
        let tweak = Tweak(feature: "feature", variable: "variable", value: "value")
        let userInfo = [TweaksConfigurationDidChangeNotificationTweakKey: tweak]
        NotificationCenter.default.post(name: TweaksConfigurationDidChangeNotification, object: self, userInfo: userInfo)
        XCTAssertFalse(didCallClosure)
    }
}

class MockTweaksRemoteConfiguration: Configuration {
    
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
