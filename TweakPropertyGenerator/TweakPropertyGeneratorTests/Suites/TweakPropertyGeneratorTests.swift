//
//  TweakPropertyGeneratorTests.swift
//  Copyright © 2021 Just Eat Takeaway. All rights reserved.
//

import XCTest

class TweakPropertyGeneratorTests: XCTestCase {
    
    private var bundle: Bundle!
    private let localConfigurationFilename = "ValidTweakProvider_LowPriority"
    private var localConfigurationFilePath: String!
    private let generatedClassName = "GeneratedConfigurationAccessor"
    private var codeGenerator: TweakPropertyCodeGenerator!
    private var localConfigurationParser: LocalConfigurationParser!
    private var tweaks: [Tweak]!
    
    override func setUpWithError() throws {
        bundle = Bundle(for: type(of: self))
        localConfigurationFilePath = bundle.path(forResource: localConfigurationFilename, ofType: "json")!
        codeGenerator = TweakPropertyCodeGenerator()
        localConfigurationParser = LocalConfigurationParser()
        tweaks = try localConfigurationParser.load(localConfigurationFilePath)
    }
    
    override func tearDownWithError() throws {
        bundle = nil
        localConfigurationFilePath = nil
        codeGenerator = nil
        localConfigurationParser = nil
        tweaks = nil
    }
    
    func test_generateConstants_output() throws {
        let configuration = Configuration(tweakProviders: [],
                                          shouldCacheTweaks: true,
                                          stackName: "GeneratedConfigurationAccessor")
        let content = codeGenerator.generateConstantsFileContent(tweaks: tweaks, configuration: configuration)
        let testContentPath = bundle.path(forResource: "GeneratedConfigurationAccessor+ConstantsContent", ofType: "")!
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
                                          stackName: "GeneratedConfigurationAccessor")
        let content = codeGenerator.generateAccessorFileContent(localConfigurationFilename: localConfigurationFilename,
                                                                tweaks: tweaks,
                                                                configuration: configuration)
        
        let testContentPath = bundle.path(forResource: "GeneratedConfigurationAccessorContent", ofType: "")!
        let testContent = try String(contentsOfFile: testContentPath, encoding: .utf8).trimmingCharacters(in: .newlines)
        
        XCTAssertEqual(content, testContent)
    }
}
