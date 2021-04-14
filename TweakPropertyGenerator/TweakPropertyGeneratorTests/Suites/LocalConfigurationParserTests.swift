//
//  LocalConfigurationParserTests.swift
//  Copyright © 2021 Just Eat Takeaway. All rights reserved.
//

import XCTest

class LocalConfigurationParserTests: XCTestCase {
    
    var sut: LocalConfigurationParser!
    
    override func setUp() {
        super.setUp()
        sut = LocalConfigurationParser()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_loadConfiguration_successCase() throws {
        let bundle = Bundle(for: type(of: self))
        let localConfigurationFilename = "ValidConfiguration"
        let localConfigurationFilePath = bundle.path(forResource: localConfigurationFilename, ofType: "json")!
        
        let localConfigurationContent = try sut.loadConfiguration(configurationFilePath: localConfigurationFilePath)
        
        let tweaks = [
            Tweak(feature: "general",
                  variable: "answer_to_the_universe",
                  title: "Definitive answer",
                  description: "Answer to the Ultimate Question of Life, the Universe, and Everything",
                  group: "General",
                  valueType: "Int"),
            Tweak(feature: "general",
                  variable: "greet_on_app_did_become_active",
                  title: "Greet on app launch",
                  description: "shows an alert on applicationDidBecomeActive",
                  group: "General",
                  valueType: "Bool"),
            Tweak(feature: "general",
                  variable: "tap_to_change_color_enabled",
                  title: "Tap to change views color",
                  description: "change the colour of the main view when receiving a tap",
                  group: "General",
                  valueType: "Bool"),
            Tweak(feature: "ui_customization",
                  variable: "display_green_view",
                  title: "Display Green View",
                  description: "shows a green view in the main view controller",
                  group: "UI Customization",
                  valueType: "Bool"),
            Tweak(feature: "ui_customization",
                  variable: "display_red_view",
                  title: "Display Red View",
                  description: "shows a red view in the main view controller",
                  group: "UI Customization",
                  valueType: "Bool"),
            Tweak(feature: "ui_customization",
                  variable: "display_yellow_view",
                  title: "Display Yellow View",
                  description: "shows a yellow view in the main view controller",
                  group: "UI Customization",
                  valueType: "Bool"),
            Tweak(feature: "ui_customization",
                  variable: "label_text",
                  title: "Label Text",
                  description: "the title of the main label",
                  group: "UI Customization",
                  valueType: "String"),
            Tweak(feature: "ui_customization",
                  variable: "red_view_alpha_component",
                  title: "Red View Alpha Component",
                  description: "defines the alpha level of the red view",
                  group: "UI Customization",
                  valueType: "Double")]
        let expectedConfiguration = Configuration(tweaks: tweaks)
        
        XCTAssertEqual(localConfigurationContent, expectedConfiguration)
    }
    
    func test_loadConfiguration_failureCase() throws {
        let bundle = Bundle(for: type(of: self))
        let localConfigurationFilename = "InvalidConfiguration"
        let localConfigurationFilePath = bundle.path(forResource: localConfigurationFilename, ofType: "json")!
        
        XCTAssertThrowsError(try sut.loadConfiguration(configurationFilePath: localConfigurationFilePath))
    }
    
    func test_typeForValue_String() {
        let expectedValue = "String"
        XCTAssertEqual(sut.type(for: "some string"), expectedValue)
    }
    
    func test_typeForValue_NSNumber_Double() {
        let expectedValue = "Double"
        XCTAssertEqual(sut.type(for: NSNumber(value: 3.14)), expectedValue)
    }
    
    func test_typeForValue_NSNumber_Int() {
        let expectedValue = "Int"
        XCTAssertEqual(sut.type(for: NSNumber(value: 42)), expectedValue)
    }
    
    func test_typeForValue_NSNumber_Bool() {
        let expectedValue = "Bool"
        XCTAssertEqual(sut.type(for: NSNumber(value: true)), expectedValue)
    }
    
    func test_typeForValue_Bool() {
        let expectedValue = "Bool"
        XCTAssertEqual(sut.type(for: true), expectedValue)
    }
    
    func test_typeForValue_Double() {
        let expectedValue = "Double"
        XCTAssertEqual(sut.type(for: 3.14), expectedValue)
    }
    
    func test_typeForValue_Unkwnown() {
        let expectedValue = "unkwown"
        XCTAssertEqual(sut.type(for: [""]), expectedValue)
    }
    
    func test_tweakForDictionary_AllRequiredValuesPresent() throws {
        let feature = "some feature"
        let variable = "some variable"
        let title = "some title"
        let description = "some description"
        let group = "some group"
        let dictionary: [String : Any] = [
            "Title": title,
            "Description": description,
            "Group": group,
            "Value": 3.14
        ]
        let expectedValue = Tweak(feature: feature,
                                  variable: variable,
                                  title: title,
                                  description: description,
                                  group: group,
                                  valueType: "Double")
        let testValue = try sut.tweak(for: dictionary,
                                      feature: feature,
                                      variable: variable)
        XCTAssertEqual(testValue, expectedValue)
    }
    
    func test_tweakForDictionary_MissingTitle() {
        let feature = "some feature"
        let variable = "some variable"
        let description = "some description"
        let group = "some group"
        let dictionary: [String : Any] = [
            "Description": description,
            "Group": group,
            "Value": 3.14
        ]
        XCTAssertThrowsError(try sut.tweak(for: dictionary, feature: feature, variable: variable))
    }
    
    func test_tweakForDictionary_MissingDescription() {
        let feature = "some feature"
        let variable = "some variable"
        let title = "some title"
        let group = "some group"
        let dictionary: [String : Any] = [
            "Title": title,
            "Group": group,
            "Value": 3.14
        ]
        XCTAssertThrowsError(try sut.tweak(for: dictionary, feature: feature, variable: variable))
    }
    
    func test_tweakForDictionary_MissingGroup() {
        let feature = "some feature"
        let variable = "some variable"
        let title = "some title"
        let description = "some description"
        let dictionary: [String : Any] = [
            "Title": title,
            "Description": description,
            "Value": 3.14
        ]
        XCTAssertThrowsError(try sut.tweak(for: dictionary, feature: feature, variable: variable))
    }
    
    func test_tweakForDictionary_MissingValue() {
        let feature = "some feature"
        let variable = "some variable"
        let title = "some title"
        let description = "some description"
        let group = "some group"
        let dictionary: [String : Any] = [
            "Title": title,
            "Description": description,
            "Group": group
        ]
        XCTAssertThrowsError(try sut.tweak(for: dictionary, feature: feature, variable: variable))
    }
}
