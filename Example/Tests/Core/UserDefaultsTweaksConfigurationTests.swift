
import XCTest
import JustTweak

class UserDefaultsTweaksConfigurationTests: XCTestCase {
    
    var userDefaultsConfiguration: UserDefaultsTweaksConfiguration!
    let userDefaults = UserDefaults(suiteName: String(describing: UserDefaultsTweaksConfigurationTests.self))!

    private let userDefaultsKeyPrefix = "lib.fragments.userDefaultsKey"

    override func setUp() {
        super.setUp()
        userDefaultsConfiguration = UserDefaultsTweaksConfiguration(userDefaults: userDefaults)
    }
    
    override func tearDown() {
        userDefaults.removeObject(forKey: "\(userDefaultsKeyPrefix).display_red_view")
        userDefaultsConfiguration = nil
        super.tearDown()
    }
    
    func testReturnsCorrectTweaksIdentifiersWhenInitializedAndTweaksHaveBeenSet() {
        let anotherConfiguration = UserDefaultsTweaksConfiguration(userDefaults: userDefaults)
        anotherConfiguration.set("hello", feature: "feature_1", variable: "variable_3")
        anotherConfiguration.set(true, feature: "feature_1", variable: "variable_2")
        anotherConfiguration.set(1, feature: "feature_1", variable: "variable_1")
        
        XCTAssertTrue(anotherConfiguration.tweakWith(feature: "feature_1", variable: "variable_1")!.value == 1)
        XCTAssertTrue(anotherConfiguration.tweakWith(feature: "feature_1", variable: "variable_2")!.value == true)
        XCTAssertTrue(anotherConfiguration.tweakWith(feature: "feature_1", variable: "variable_3")!.value == "hello")
    }
    
    func testReturnsNilForTweaksThatHaveNoUserDefaultValue() {
        let tweak = userDefaultsConfiguration.tweakWith(feature: Features.UICustomization.rawValue, variable: Variables.DisplayRedView.rawValue)
        XCTAssertNil(tweak)
    }
    
    func testUpdatesValueForTweak_withBool() {
        userDefaultsConfiguration.set(value: true, feature: "feature_1", variable: "variable_1")
        let tweak = userDefaultsConfiguration.tweakWith(feature: "feature_1", variable: "variable_1")
        XCTAssertTrue(tweak!.value == true)
    }
    
    func testUpdatesValueForTweak_withNumber() {
        userDefaultsConfiguration.set(value: 42, feature: "feature_1", variable: "variable_1")
        let tweak = userDefaultsConfiguration.tweakWith(feature: "feature_1", variable: "variable_1")
        XCTAssertTrue(tweak!.value == 42)
    }
    
    func testUpdatesValueForTweak_withString() {
        userDefaultsConfiguration.set(value: "Hello", feature: "feature_1", variable: "variable_1")
        let tweak = userDefaultsConfiguration.tweakWith(feature: "feature_1", variable: "variable_1")
        XCTAssertTrue(tweak!.value == "Hello")
    }    
}
