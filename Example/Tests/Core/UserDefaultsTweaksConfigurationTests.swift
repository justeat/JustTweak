
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
        let tweak = userDefaultsConfiguration.tweakWith(feature: Features.UICustomization, variable: Variables.DisplayRedView)
        XCTAssertNil(tweak)
    }
    
    func testUpdatesValueForTweak_withBool() {
        userDefaultsConfiguration.set(true, feature: "feature_1", variable: "variable_1")
        let tweak = userDefaultsConfiguration.tweakWith(feature: "feature_1", variable: "variable_1")
        XCTAssertTrue(tweak!.value == true)
    }
    
    func testUpdatesValueForTweak_withInteger() {
        userDefaultsConfiguration.set(42, feature: "feature_1", variable: "variable_1")
        let tweak = userDefaultsConfiguration.tweakWith(feature: "feature_1", variable: "variable_1")
        XCTAssertTrue(tweak!.value == 42)
    }
    
    func testUpdatesValueForTweak_withFloat() {
        userDefaultsConfiguration.set(Float(12.34), feature: "feature_1", variable: "variable_1")
        let tweak = userDefaultsConfiguration.tweakWith(feature: "feature_1", variable: "variable_1")
        XCTAssertTrue(tweak!.value == Float(12.34))
    }
    
    func testUpdatesValueForTweak_withDouble() {
        userDefaultsConfiguration.set(Double(23.45), feature: "feature_1", variable: "variable_1")
        let tweak = userDefaultsConfiguration.tweakWith(feature: "feature_1", variable: "variable_1")
        XCTAssertTrue(tweak!.value == Double(23.45))
    }
    
    func testUpdatesValueForTweak_withString() {
        userDefaultsConfiguration.set("Hello", feature: "feature_1", variable: "variable_1")
        let tweak = userDefaultsConfiguration.tweakWith(feature: "feature_1", variable: "variable_1")
        XCTAssertTrue(tweak!.value == "Hello")
    }    
}
