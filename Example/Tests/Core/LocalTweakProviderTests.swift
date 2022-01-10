//
//  LocalTweakProviderTests.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import XCTest
import JustTweak

class LocalTweakProviderTests: XCTestCase {
    
    private var tweakProvider: LocalTweakProvider!
    
    override func setUp() {
        super.setUp()
        tweakProvider = tweakProviderWithFileNamed("LocalTweaks_test")!
    }
    
    override func tearDown() {
        tweakProvider = nil
        super.tearDown()
    }
    
    private func tweakProviderWithFileNamed(_ fileName: String) -> LocalTweakProvider? {
        let bundle = Bundle(for: LocalTweakProviderTests.self)
        let jsonURL = bundle.url(forResource: fileName, withExtension: "json")!
        return LocalTweakProvider(jsonURL: jsonURL)
    }
    
    func testParsesBoolTweak() {
        let redViewTweak = Tweak(feature: Features.uiCustomization,
                                 variable: Variables.displayRedView,
                                 value: true,
                                 title: "Display Red View",
                                 group: "UI Customization")
        XCTAssertEqual(redViewTweak, try tweakProvider.tweakWith(feature: Features.uiCustomization,
                                                                 variable: Variables.displayRedView))
    }
    
    func testParsesFloatTweak() {
        let redViewAlphaTweak = Tweak(feature: Features.uiCustomization,
                                      variable: Variables.redViewAlpha,
                                      value: 1.0,
                                      title: "Red View Alpha Component",
                                      group: "UI Customization")
        XCTAssertEqual(redViewAlphaTweak, try tweakProvider.tweakWith(feature: Features.uiCustomization,
                                                                      variable: Variables.redViewAlpha))
    }
    
    func testParsesStringTweak() {
        let buttonLabelTweak = Tweak(feature: Features.uiCustomization,
                                     variable: Variables.labelText,
                                     value: "Test value",
                                     title: "Label Text", group: "UI Customization")
        XCTAssertEqual(buttonLabelTweak, try tweakProvider.tweakWith(feature: Features.uiCustomization,
                                                                     variable: Variables.labelText))
    }
    
    func testDecryptionClosure() {
        XCTAssertNil(tweakProvider.decryptionClosure)
        
        tweakProvider.decryptionClosure = { tweak in
            (tweak.value.stringValue ?? "") + "Decrypted"
        }
        
        let tweak = Tweak(feature: "feature", variable: "variable", value: "topSecret")
        let decryptedTweak = tweakProvider.decryptionClosure?(tweak)
        
        XCTAssertEqual(decryptedTweak?.stringValue, "topSecretDecrypted")
    }
}
