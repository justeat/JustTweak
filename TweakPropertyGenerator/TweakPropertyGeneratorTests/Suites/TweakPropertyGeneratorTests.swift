//
//  TweakPropertyGeneratorTests.swift
//  Copyright © 2021 Just Eat Takeaway. All rights reserved.
//

import XCTest

class TweakPropertyGeneratorTests: XCTestCase {
    
    private var bundle: Bundle!
    private let localConfigurationFilename = "ValidConfiguration"
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
        let content = codeGenerator.generateConstantsFileContent(className: generatedClassName,
                                                                 tweaks: tweaks)
        
        let testContentPath = bundle.path(forResource: "GeneratedConfigurationAccessor+ConstantsContent", ofType: "")!
        let testContent = try String(contentsOfFile: testContentPath, encoding: .utf8).trimmingCharacters(in: .newlines)
        
        XCTAssertEqual(content, testContent)
    }
    
    func test_generateAccessor_output() throws {
        let configurations = [
            Configuration(type: "UserDefaultsConfiguration",
                          parameter: "UserDefaults.standard",
                          macros: ["DEBUG", "CONFIGURATION_DEBUG"]),
            Configuration(type: "LocalConfiguration",
                          parameter: "ValidConfiguration_TopPriority",
                          macros: ["DEBUG"]),
            Configuration(type: "LocalConfiguration",
                          parameter: "ValidConfiguration_LowPriority",
                          macros: nil)
        ]
        let content = codeGenerator.generateAccessorFileContent(localConfigurationFilename: localConfigurationFilename,
                                                                className: generatedClassName,
                                                                tweaks: tweaks,
                                                                configurations: configurations)
        
        let testContentPath = bundle.path(forResource: "GeneratedConfigurationAccessorContent", ofType: "")!
        let testContent = try String(contentsOfFile: testContentPath, encoding: .utf8).trimmingCharacters(in: .newlines)
        
        XCTAssertEqual(content, testContent)
    }
}
