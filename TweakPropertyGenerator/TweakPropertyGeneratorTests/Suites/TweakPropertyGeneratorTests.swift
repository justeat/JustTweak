//
//  TweakPropertyGeneratorTests.swift
//  Copyright © 2021 Just Eat Takeaway. All rights reserved.
//

import XCTest

class TweakPropertyGeneratorTests: XCTestCase {
    
    private var bundle: Bundle!
    private let localConfigurationFilename = "ValidConfiguration_LowPriority"
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
        let configuration = Configuration(configurations: [],
                                          shouldCacheTweaks: true,
                                          stackName: "GeneratedConfigurationAccessor")
        let content = codeGenerator.generateConstantsFileContent(tweaks: tweaks, configuration: configuration)
        let testContentPath = bundle.path(forResource: "GeneratedConfigurationAccessor+ConstantsContent", ofType: "")!
        let testContent = try String(contentsOfFile: testContentPath, encoding: .utf8).trimmingCharacters(in: .newlines)
        XCTAssertEqual(content, testContent)
    }
    
    func test_generateAccessor_output() throws {
        let configurations = [
            TweakConfiguration(type: "UserDefaultsConfiguration",
                               parameter: "UserDefaults.standard",
                               propertyName: nil,
                               macros: ["DEBUG", "CONFIGURATION_DEBUG"]),
            TweakConfiguration(type: "CustomConfiguration",
                               parameter: "let optimizelyConfiguration = OptimizelyConfiguration()\n        oc.someValue = 42",
                               propertyName: "optimizelyConfiguration",
                               macros: ["CONFIGURATION_APPSTORE"]),
            TweakConfiguration(type: "CustomConfiguration",
                               parameter: "let firebaseConfiguration = FirebaseConfiguration()\n        fc.someValue = true",
                               propertyName: "firebaseConfiguration",
                               macros: ["CONFIGURATION_APPSTORE"]),
            TweakConfiguration(type: "LocalConfiguration",
                               parameter: "ValidConfiguration_TopPriority",
                               propertyName: nil,
                               macros: ["DEBUG"]),
            TweakConfiguration(type: "LocalConfiguration",
                               parameter: "ValidConfiguration_LowPriority",
                               propertyName: nil,
                               macros: nil)
        ]
        let configuration = Configuration(configurations: configurations,
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
