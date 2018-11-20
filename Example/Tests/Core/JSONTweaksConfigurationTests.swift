
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
        let redViewTweak = Tweak(identifier: Variables.DisplayRedView.rawValue, title: "Display Red View", group: "UI", value: true, canBeDisplayed: true)
        XCTAssertEqual(redViewTweak, configuration.tweakWith(feature: Features.UICustomization.rawValue, variable: Variables.DisplayRedView.rawValue))
    }
    
    func testParsesBoolTweakWithOneValue() {
        let tapBisTweak = Tweak(identifier: Variables.TapToChangeViewColor.rawValue, title: nil, group: nil, value: true, canBeDisplayed: true)
        XCTAssertEqual(tapBisTweak, configuration.tweakWith(feature: Features.UICustomization.rawValue, variable: Variables.TapToChangeViewColor.rawValue))
    }
    
    func testParsesFloatTweakWithAllValues() {
        let redViewAlphaTweak = Tweak(identifier: Variables.RedViewAlpha.rawValue, title: "Red View Alpha Component", group: "UI", value: 1.0, canBeDisplayed: true)
        XCTAssertEqual(redViewAlphaTweak, configuration.tweakWith(feature: Features.UICustomization.rawValue, variable: Variables.RedViewAlpha.rawValue))
    }
    
    func testParsesStringTweakWithAllValues() {
        let buttonLabelTweak = Tweak(identifier: Variables.ChangeConfigurationButton.rawValue, title: "Change Tweaks Button Label Text", group: "UI", value: "Change Configuration", canBeDisplayed: true)
        XCTAssertEqual(buttonLabelTweak, configuration.tweakWith(feature: Features.UICustomization.rawValue, variable: Variables.ChangeConfigurationButton.rawValue))
    }
    
}
