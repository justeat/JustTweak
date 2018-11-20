
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
    
    func testParsesBoolTweak() {
        let identifier = self.identifier(for: Features.UICustomization.rawValue, variable: Variables.DisplayRedView.rawValue)
        let redViewTweak = Tweak(identifier: identifier, title: "Display Red View", group: "UI Customization", value: true)
        XCTAssertEqual(redViewTweak, configuration.tweakWith(feature: Features.UICustomization.rawValue, variable: Variables.DisplayRedView.rawValue))
    }
    
    func testParsesFloatTweak() {
        let identifier = self.identifier(for: Features.UICustomization.rawValue, variable: Variables.RedViewAlpha.rawValue)
        let redViewAlphaTweak = Tweak(identifier: identifier, title: "Red View Alpha Component", group: "UI Customization", value: 1.0)
        XCTAssertEqual(redViewAlphaTweak, configuration.tweakWith(feature: Features.UICustomization.rawValue, variable: Variables.RedViewAlpha.rawValue))
    }
    
    func testParsesStringTweak() {
        let identifier = self.identifier(for: Features.UICustomization.rawValue, variable: Variables.ChangeConfigurationButton.rawValue)
        let buttonLabelTweak = Tweak(identifier: identifier, title: "Change Tweaks Button Label Text", group: "UI Customization", value: "Change Configuration")
        XCTAssertEqual(buttonLabelTweak, configuration.tweakWith(feature: Features.UICustomization.rawValue, variable: Variables.ChangeConfigurationButton.rawValue))
    }
    
    private func identifier(for feature: String, variable: String) -> String {
        return [feature, variable].joined(separator: "-")
    }
}
