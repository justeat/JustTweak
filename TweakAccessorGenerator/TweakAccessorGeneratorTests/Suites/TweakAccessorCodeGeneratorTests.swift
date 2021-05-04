//
//  TweakAccessorCodeGeneratorTests.swift
//  Copyright © 2021 Just Eat Takeaway. All rights reserved.
//

import XCTest

class TweakAccessorCodeGeneratorTests: XCTestCase {
    
    private var bundle: Bundle!
    private let tweaksFilename = "ValidTweaks_LowPriority"
    private var tweaksFilePath: String!
    private let generatedClassName = "GeneratedTweakAccessor"
    private var codeGenerator: TweakAccessorCodeGenerator!
    private var tweakLoader: TweakLoader!
    private var tweaks: [Tweak]!
    
    override func setUpWithError() throws {
        bundle = Bundle(for: type(of: self))
        tweaksFilePath = bundle.path(forResource: tweaksFilename, ofType: "json")!
        codeGenerator = TweakAccessorCodeGenerator()
        tweakLoader = TweakLoader()
        tweaks = try tweakLoader.load(tweaksFilePath)
    }
    
    override func tearDownWithError() throws {
        bundle = nil
        tweaksFilePath = nil
        codeGenerator = nil
        tweakLoader = nil
        tweaks = nil
    }
    
    func test_generateConstants_output() throws {
        let configuration = Configuration(tweakProviders: [],
                                          shouldCacheTweaks: true,
                                          usePropertyWrappers: true,
                                          accessorName: "GeneratedTweakAccessorContent")
        let content = codeGenerator.generateConstantsFileContent(tweaks: tweaks, configuration: configuration)
        let testContentPath = bundle.path(forResource: "GeneratedTweakAccessor+ConstantsContent", ofType: "")!
        let testContent = try String(contentsOfFile: testContentPath, encoding: .utf8).trimmingCharacters(in: .newlines)
        XCTAssertEqual(content, testContent)
    }
    
    func test_generateAccessor_PropertyWrappers_output() throws {
        let tweakProviders = [
            TweakProvider(type: "EphemeralTweakProvider",
                          parameter: nil,
                          macros: ["DEBUG", "CONFIGURATION_UI_TESTS"]),
            TweakProvider(type: "UserDefaultsTweakProvider",
                          parameter: "UserDefaults.standard",
                          macros: ["DEBUG", "CONFIGURATION_DEBUG"]),
            TweakProvider(type: "CustomTweakProvider",
                          parameter: "OptimizelyTweakProviderSetupCode",
                          macros: ["CONFIGURATION_APPSTORE"]),
            TweakProvider(type: "CustomTweakProvider",
                          parameter: "FirebaseTweakProviderSetupCode",
                          macros: ["CONFIGURATION_APPSTORE"]),
            TweakProvider(type: "LocalTweakProvider",
                          parameter: "ValidTweaks_TopPriority",
                          macros: ["DEBUG"]),
            TweakProvider(type: "LocalTweakProvider",
                          parameter: "ValidTweaks_LowPriority",
                          macros: nil)
        ]
        let configuration = Configuration(tweakProviders: tweakProviders,
                                          shouldCacheTweaks: true,
                                          usePropertyWrappers: true,
                                          accessorName: "GeneratedTweakAccessorContent")
        let customTweakProvidersSetupCode = [
            "FirebaseTweakProviderSetupCode": codeBlock(for: "FirebaseTweakProviderSetupCode"),
            "OptimizelyTweakProviderSetupCode": codeBlock(for: "OptimizelyTweakProviderSetupCode"),
            
        ]
        let content = codeGenerator.generateAccessorFileContent(tweaksFilename: tweaksFilename,
                                                                tweaks: tweaks,
                                                                configuration: configuration,
                                                                customTweakProvidersSetupCode: customTweakProvidersSetupCode)
        let testContentPath = bundle.path(forResource: "GeneratedTweakAccessorContent_PropertyWrappers", ofType: "")!
        let testContent = try String(contentsOfFile: testContentPath, encoding: .utf8).trimmingCharacters(in: .newlines)
        
        XCTAssertEqual(content, testContent)
    }
    
    func test_generateAccessor_NoPropertyWrappers_output() throws {
        let tweakProviders = [
            TweakProvider(type: "EphemeralTweakProvider",
                          parameter: nil,
                          macros: ["DEBUG", "CONFIGURATION_UI_TESTS"]),
            TweakProvider(type: "UserDefaultsTweakProvider",
                          parameter: "UserDefaults.standard",
                          macros: ["DEBUG", "CONFIGURATION_DEBUG"]),
            TweakProvider(type: "CustomTweakProvider",
                          parameter: "OptimizelyTweakProviderSetupCode",
                          macros: ["CONFIGURATION_APPSTORE"]),
            TweakProvider(type: "CustomTweakProvider",
                          parameter: "FirebaseTweakProviderSetupCode",
                          macros: ["CONFIGURATION_APPSTORE"]),
            TweakProvider(type: "LocalTweakProvider",
                          parameter: "ValidTweaks_TopPriority",
                          macros: ["DEBUG"]),
            TweakProvider(type: "LocalTweakProvider",
                          parameter: "ValidTweaks_LowPriority",
                          macros: nil)
        ]
        let configuration = Configuration(tweakProviders: tweakProviders,
                                          shouldCacheTweaks: true,
                                          usePropertyWrappers: false,
                                          accessorName: "GeneratedTweakAccessorContent")
        let customTweakProvidersSetupCode = [
            "FirebaseTweakProviderSetupCode": codeBlock(for: "FirebaseTweakProviderSetupCode"),
            "OptimizelyTweakProviderSetupCode": codeBlock(for: "OptimizelyTweakProviderSetupCode"),
            
        ]
        let content = codeGenerator.generateAccessorFileContent(tweaksFilename: tweaksFilename,
                                                                tweaks: tweaks,
                                                                configuration: configuration,
                                                                customTweakProvidersSetupCode: customTweakProvidersSetupCode)
        let testContentPath = bundle.path(forResource: "GeneratedTweakAccessorContent_NoPropertyWrappers", ofType: "")!
        let testContent = try String(contentsOfFile: testContentPath, encoding: .utf8).trimmingCharacters(in: .newlines)
        
        XCTAssertEqual(content, testContent)
    }
    
    private func codeBlock(for customTweakProviderFile: String) -> String {
        let testBundle = Bundle(for: TweakAccessorCodeGeneratorTests.self)
        let filePath = testBundle.path(forResource: customTweakProviderFile, ofType: "")!
        return try! String(contentsOfFile: filePath)
    }
}
