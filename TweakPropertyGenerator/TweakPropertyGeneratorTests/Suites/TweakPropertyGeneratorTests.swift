//
//  TweakPropertyGeneratorTests.swift
//  Copyright © 2021 Just Eat Takeaway. All rights reserved.
//

import XCTest

class TweakPropertyGeneratorTests: XCTestCase {
    
    private var bundle: Bundle!
    private let tweaksFilename = "ValidTweakProvider_LowPriority"
    private var tweaksFilePath: String!
    private let generatedClassName = "GeneratedTweakAccessorContent"
    private var codeGenerator: TweakPropertyCodeGenerator!
    private var localConfigurationParser: TweakParser!
    private var tweaks: [Tweak]!
    
    override func setUpWithError() throws {
        bundle = Bundle(for: type(of: self))
        tweaksFilePath = bundle.path(forResource: tweaksFilename, ofType: "json")!
        codeGenerator = TweakPropertyCodeGenerator()
        localConfigurationParser = TweakParser()
        tweaks = try localConfigurationParser.load(tweaksFilePath)
    }
    
    override func tearDownWithError() throws {
        bundle = nil
        tweaksFilePath = nil
        codeGenerator = nil
        localConfigurationParser = nil
        tweaks = nil
    }
    
    func test_generateConstants_output() throws {
        let configuration = Configuration(tweakProviders: [],
                                          shouldCacheTweaks: true,
                                          stackName: "GeneratedTweakAccessorContent")
        let content = codeGenerator.generateConstantsFileContent(tweaks: tweaks, configuration: configuration)
        let testContentPath = bundle.path(forResource: "GeneratedTweakAccessorContent+ConstantsContent", ofType: "")!
        let testContent = try String(contentsOfFile: testContentPath, encoding: .utf8).trimmingCharacters(in: .newlines)
        XCTAssertEqual(content, testContent)
    }
    
    func test_generateAccessor_output() throws {
        let tweakProviders = [
            TweakProvider(type: "UserDefaultsTweakProvider",
                          parameter: "UserDefaults.standard",
                          propertyName: nil,
                          macros: ["DEBUG", "CONFIGURATION_DEBUG"]),
            TweakProvider(type: "CustomTweakProvider",
                          parameter: "let optimizelyTweakProvider = OptimizelyTweakProvider()\n        optimizelyTweakProvider.someValue = 42",
                          propertyName: "optimizelyTweakProvider",
                          macros: ["CONFIGURATION_APPSTORE"]),
            TweakProvider(type: "CustomTweakProvider",
                          parameter: "let firebaseTweakProvider = FirebaseTweakProvider()\n        firebaseTweakProvider.someValue = true",
                          propertyName: "firebaseTweakProvider",
                          macros: ["CONFIGURATION_APPSTORE"]),
            TweakProvider(type: "LocalTweakProvider",
                          parameter: "ValidTweakProvider_TopPriority",
                          propertyName: nil,
                          macros: ["DEBUG"]),
            TweakProvider(type: "LocalTweakProvider",
                          parameter: "ValidTweakProvider_LowPriority",
                          propertyName: nil,
                          macros: nil)
        ]
        let configuration = Configuration(tweakProviders: tweakProviders,
                                          shouldCacheTweaks: true,
                                          stackName: "GeneratedTweakAccessorContent")
        let content = codeGenerator.generateAccessorFileContent(tweaksFilename: tweaksFilename,
                                                                tweaks: tweaks,
                                                                configuration: configuration)
        
        let testContentPath = bundle.path(forResource: "GeneratedTweakAccessorContent", ofType: "")!
        let testContent = try String(contentsOfFile: testContentPath, encoding: .utf8).trimmingCharacters(in: .newlines)
        
        XCTAssertEqual(content, testContent)
    }
}
