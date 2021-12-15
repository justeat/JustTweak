//
//  TweakLoaderTests.swift
//  Copyright © 2021 Just Eat Takeaway. All rights reserved.
//

import XCTest

class TweakLoaderTests: XCTestCase {
    
    var sut: TweakLoader!
    
    override func setUp() {
        super.setUp()
        sut = TweakLoader()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_loadConfiguration_success() throws {
        let bundle = Bundle(for: type(of: self))
        let tweaksFilename = "Tweaks"
        let tweaksFilePath = bundle.path(forResource: tweaksFilename, ofType: "json")!
        
        let testTweaks = try sut.load(tweaksFilePath)
        
        let expectedTweaks = [
            Tweak(feature: "general",
                  variable: "answer_to_the_universe",
                  title: "Definitive answer",
                  description: "Answer to the Ultimate Question of Life, the Universe, and Everything",
                  group: "General",
                  valueType: "Int",
                  propertyName: "definitiveAnswer"),
            Tweak(feature: "general",
                  variable: "encrypted_answer_to_the_universe",
                  title: "Encrypted definitive answer",
                  description: "Encrypted answer to the Ultimate Question of Life, the Universe, and Everything",
                  group: "General",
                  valueType: "String",
                  propertyName: "definitiveAnswerEncrypted"),
            Tweak(feature: "general",
                  variable: "greet_on_app_did_become_active",
                  title: "Greet on app launch",
                  description: "shows an alert on applicationDidBecomeActive",
                  group: "General",
                  valueType: "Bool",
                  propertyName: nil),
            Tweak(feature: "general",
                  variable: "tap_to_change_color_enabled",
                  title: "Tap to change views color",
                  description: "change the colour of the main view when receiving a tap",
                  group: "General",
                  valueType: "Bool",
                  propertyName: nil),
            Tweak(feature: "ui_customization",
                  variable: "display_green_view",
                  title: "Display Green View",
                  description: "shows a green view in the main view controller",
                  group: "UI Customization",
                  valueType: "Bool",
                  propertyName: nil),
            Tweak(feature: "ui_customization",
                  variable: "display_red_view",
                  title: "Display Red View",
                  description: "shows a red view in the main view controller",
                  group: "UI Customization",
                  valueType: "Bool",
                  propertyName: nil),
            Tweak(feature: "ui_customization",
                  variable: "display_yellow_view",
                  title: "Display Yellow View",
                  description: "shows a yellow view in the main view controller",
                  group: "UI Customization",
                  valueType: "Bool",
                  propertyName: nil),
            Tweak(feature: "ui_customization",
                  variable: "label_text",
                  title: "Label Text",
                  description: "the title of the main label",
                  group: "UI Customization",
                  valueType: "String",
                  propertyName: nil),
            Tweak(feature: "ui_customization",
                  variable: "red_view_alpha_component",
                  title: "Red View Alpha Component",
                  description: "defines the alpha level of the red view",
                  group: "UI Customization",
                  valueType: "Double",
                  propertyName: nil)]
        XCTAssertEqual(testTweaks, expectedTweaks)
    }
    
    func test_loadConfiguration_failure_invalidJSON() throws {
        let bundle = Bundle(for: type(of: self))
        let tweaksFilename = "InvalidTweaks_InvalidJSON"
        let tweaksFilePath = bundle.path(forResource: tweaksFilename, ofType: "json")!
        
        XCTAssertThrowsError(try sut.load(tweaksFilePath))
    }
    
    func test_loadConfiguration_failure_missingValues() throws {
        let bundle = Bundle(for: type(of: self))
        let tweaksFilename = "InvalidTweaks_MissingValues"
        let tweaksFilePath = bundle.path(forResource: tweaksFilename, ofType: "json")!
        
        XCTAssertThrowsError(try sut.load(tweaksFilePath))
    }
    
    func test_loadConfiguration_failure_duplicateGeneratedPropertyName() throws {
        let bundle = Bundle(for: type(of: self))
        let tweaksFilename = "InvalidTweaks_DuplicateGeneratedPropertyName"
        let tweaksFilePath = bundle.path(forResource: tweaksFilename, ofType: "json")!
        XCTAssertThrowsError(try sut.load(tweaksFilePath))
    }
    
    func test_typeForValue_String() {
        let expectedValue = "String"
        XCTAssertEqual(try sut.type(for: "some string"), expectedValue)
    }
    
    func test_typeForValue_NSNumber_Double() {
        let expectedValue = "Double"
        XCTAssertEqual(try sut.type(for: NSNumber(value: 3.14)), expectedValue)
    }
    
    func test_typeForValue_NSNumber_Int() {
        let expectedValue = "Int"
        XCTAssertEqual(try sut.type(for: NSNumber(value: 42)), expectedValue)
    }
    
    func test_typeForValue_NSNumber_Bool() {
        let expectedValue = "Bool"
        XCTAssertEqual(try sut.type(for: NSNumber(value: true)), expectedValue)
    }
    
    func test_typeForValue_Bool() {
        let expectedValue = "Bool"
        XCTAssertEqual(try sut.type(for: true), expectedValue)
    }
    
    func test_typeForValue_Double() {
        let expectedValue = "Double"
        XCTAssertEqual(try sut.type(for: 3.14), expectedValue)
    }
    
    func test_typeForValue_Unsupported() {
        XCTAssertThrowsError(try sut.type(for: [""]))
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
                                  valueType: "Double",
                                  propertyName: nil)
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
        XCTAssertNoThrow(try sut.tweak(for: dictionary, feature: feature, variable: variable))
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
