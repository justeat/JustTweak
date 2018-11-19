
import XCTest
import JustTweak

class UserDefaultsTweaksConfigurationTests: XCTestCase {
    
    var configuration: UserDefaultsTweaksConfiguration!
    let userDefaults = UserDefaults(suiteName: String(describing: UserDefaultsTweaksConfigurationTests.self))!
    
    override func setUp() {
        super.setUp()
        let bundle = Bundle(for: TweaksConfigurationCoordinatorTests.self)
        let jsonConfigurationURL = bundle.url(forResource: "test_configuration", withExtension: "json")!
        let jsonConfiguration = JSONTweaksConfiguration(defaultValuesFromJSONAtURL: jsonConfigurationURL)!
        configuration = UserDefaultsTweaksConfiguration(userDefaults: userDefaults,
                                                        fallbackConfiguration: jsonConfiguration)
    }
    
    override func tearDown() {
        userDefaults.removeObject(forKey: "lib.fragments.userDefaultsKey.display_red_view")
        configuration = nil
        super.tearDown()
    }
    
    func testReturnsNoTweaksIdentifiersWhenInitializedWithoutFallbackConfigurationsAndNoTweaksHaveBeenSet() {
        let anotherConfiguration = UserDefaultsTweaksConfiguration(userDefaults: userDefaults)
        XCTAssertEqual(anotherConfiguration.allTweakIdentifiers, [])
    }
    
    func testReturnsCorrectTweaksIdentifiersWhenInitializedWithoutFallbackConfigurationsAndTweaksHaveBeenSet() {
        let anotherConfiguration = UserDefaultsTweaksConfiguration(userDefaults: userDefaults)
        anotherConfiguration.set(stringValue: "hello", forTweakWithIdentifier: "tweak_3")
        anotherConfiguration.set(boolValue: true, forTweakWithIdentifier: "tweak_2")
        anotherConfiguration.set(value: 1, forTweakWithIdentifier: "tweak_1")
        XCTAssertEqual(anotherConfiguration.allTweakIdentifiers, ["tweak_1", "tweak_2", "tweak_3"])
    }
    
    func testReturnsExpectedTweakWhenValueIsSetAndHasNoFallbackConfiguration() {
        let anotherConfiguration = UserDefaultsTweaksConfiguration(userDefaults: userDefaults)
        anotherConfiguration.set(value: true, forTweakWithIdentifier: "tweak_1")
        let expectedTweak = Tweak(identifier: "tweak_1", title: nil, group: nil, value: true, canBeDisplayed: false)
        XCTAssertTrue(anotherConfiguration.tweakWith(feature: "tweak_1") == expectedTweak)
    }
    
    func testReturnsNilForTweaksThatHaveNoUserDefaultValue() {
        XCTAssertNil(configuration.tweakWith(feature: "display_red_view"))
    }
    
    func testReturnsNonNilForTweaksThatHaveNoUserDefaultValue() {
        userDefaults.set("Hello", forKey: "lib.fragments.userDefaultsKey.display_red_view")
        XCTAssertNotNil(configuration.tweakWith(feature: "display_red_view"))
    }
    
    func testUpdatesValueForTweak_withBool() {
        configuration.set(value: true, forTweakWithIdentifier: "display_red_view")
        let tweak = configuration.tweakWith(feature: "display_red_view")
        XCTAssertTrue(tweak!.value == true)
    }
    
    func testUpdatesValueForTweak_withNumber() {
        configuration.set(value: 1, forTweakWithIdentifier: "display_red_view")
        let tweak = configuration.tweakWith(feature: "display_red_view")
        XCTAssertTrue(tweak!.value == 1)
    }
    
    func testUpdatesValueForTweak_withString() {
        configuration.set(value: "Hello", forTweakWithIdentifier: "display_red_view")
        let tweak = configuration.tweakWith(feature: "display_red_view")
        XCTAssertTrue(tweak!.value == "Hello")
    }
    
    func testUpdatesValueForTweak_withBool_withSupportForObjectiveC() {
        configuration.set(boolValue: true, forTweakWithIdentifier: "display_red_view")
        let tweak = configuration.tweakWith(feature: "display_red_view")
        XCTAssertTrue(tweak!.value == true)
    }
    
    func testUpdatesValueForTweak_withNumber_withSupportForObjectiveC() {
        configuration.set(numberValue: NSNumber(value: 1), forTweakWithIdentifier: "display_red_view")
        let tweak = configuration.tweakWith(feature: "display_red_view")
        XCTAssertTrue(tweak!.value == 1)
    }
    
    func testUpdatesValueForTweak_withString_withSupportForObjectiveC() {
        configuration.set(stringValue: "Hello", forTweakWithIdentifier: "display_red_view")
        let tweak = configuration.tweakWith(feature: "display_red_view")
        XCTAssertTrue(tweak!.value == "Hello")
    }
    
}
