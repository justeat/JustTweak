
import XCTest
import JustTweak

class JSONTweaksConfigurationTests: XCTestCase {
    
    var configuration: JSONTweaksConfiguration!
    
    override func setUp() {
        super.setUp()
        configuration = configurationWithFileNamed("test_configuration")!
    }
    
    override func tearDown() {
        configuration = nil
        super.tearDown()
    }
    
    private func configurationWithFileNamed(_ fileName: String) -> JSONTweaksConfiguration? {
        let bundle = Bundle(for: JSONTweaksConfigurationTests.self)
        let jsonURL = bundle.url(forResource: fileName, withExtension: "json")!
        return JSONTweaksConfiguration(defaultValuesFromJSONAtURL: jsonURL)
    }
    
    func testGetsNilInitialized_IfURLContainsNoData() {
        let fileURL = URL(fileURLWithPath: "/none")
        XCTAssertNil(JSONTweaksConfiguration(defaultValuesFromJSONAtURL: fileURL))
    }
    
    func testGetsNilInitialized_IfJSONIsInvalid() {
        XCTAssertNil(configurationWithFileNamed("test_configuration_invalid"))
    }
    
    func testParsesBoolTweakWithAllValues() {
        let redViewTweak = Tweak(identifier: "display_red_view", title: "Display Red View", group: "UI", value: true, canBeDisplayed: true)
        XCTAssertEqual(redViewTweak, configuration.tweakWith(feature: "display_red_view"))
    }
    
    func testParsesBoolTweakWithOneValue() {
        let tapBisTweak = Tweak(identifier: "tap_to_change_color_enabled_bis", title: nil, group: nil, value: false, canBeDisplayed: false)
        XCTAssertEqual(tapBisTweak, configuration.tweakWith(feature: "tap_to_change_color_enabled_bis"))
    }
    
    func testParsesFloatTweakWithAllValues() {
        let redViewAlphaTweak = Tweak(identifier: "red_view_alpha_component", title: "Red View Alpha Component", group: "UI", value: 1.0, canBeDisplayed: true)
        XCTAssertEqual(redViewAlphaTweak, configuration.tweakWith(feature: "red_view_alpha_component"))
    }
    
    func testParsesStringTweakWithAllValues() {
        let buttonLabelTweak = Tweak(identifier: "change_tweaks_button_label_text", title: "Change Tweaks Button Label Text", group: "UI", value: "Change Configuration", canBeDisplayed: true)
        XCTAssertEqual(buttonLabelTweak, configuration.tweakWith(feature: "change_tweaks_button_label_text"))
    }
    
}
