
import XCTest
import JustTweak

class LocalConfigurationTests: XCTestCase {
    
    var configuration: LocalConfiguration!
    
    override func setUp() {
        super.setUp()
        configuration = configurationWithFileNamed("test_configuration")!
    }
    
    override func tearDown() {
        configuration = nil
        super.tearDown()
    }
    
    private func configurationWithFileNamed(_ fileName: String) -> LocalConfiguration? {
        let bundle = Bundle(for: LocalConfigurationTests.self)
        let jsonURL = bundle.url(forResource: fileName, withExtension: "json")!
        return LocalConfiguration(jsonURL: jsonURL)
    }
    
    func testGetsNilInitialized_IfURLContainsNoData() {
        let fileURL = URL(fileURLWithPath: "/none")
        XCTAssertNil(LocalConfiguration(jsonURL: fileURL))
    }
    
    func testGetsNilInitialized_IfJSONIsInvalid() {
        XCTAssertNil(configurationWithFileNamed("test_configuration_invalid"))
    }
    
    func testParsesBoolTweak() {
        let redViewTweak = Tweak(feature: Features.UICustomization, variable: Variables.DisplayRedView, value: true, title: "Display Red View", group: "UI Customization")
        XCTAssertEqual(redViewTweak, configuration.tweakWith(feature: Features.UICustomization, variable: Variables.DisplayRedView))
    }
    
    func testParsesFloatTweak() {
        let redViewAlphaTweak = Tweak(feature: Features.UICustomization, variable: Variables.RedViewAlpha, value: 1.0, title: "Red View Alpha Component", group: "UI Customization")
        XCTAssertEqual(redViewAlphaTweak, configuration.tweakWith(feature: Features.UICustomization, variable: Variables.RedViewAlpha))
    }
    
    func testParsesStringTweak() {
        let buttonLabelTweak = Tweak(feature: Features.UICustomization, variable: Variables.LabelText, value: "Test value", title: "Label Text", group: "UI Customization")
        XCTAssertEqual(buttonLabelTweak, configuration.tweakWith(feature: Features.UICustomization, variable: Variables.LabelText))
    }
}
