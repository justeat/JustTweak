//
//  TweakPropertyGeneratorTests.swift
//  Copyright © 2021 Just Eat Takeaway. All rights reserved.
//

import XCTest

class TweakPropertyGeneratorTests: XCTestCase {
    
    func test_generateConstants_output() throws {
        let bundle = Bundle(for: type(of: self))
        let localConfigurationFilename = "ValidConfiguration"
        let localConfigurationFilePath = bundle.path(forResource: localConfigurationFilename, ofType: "json")!
        let className = "GeneratedConfigurationAccessor"
        
        let codeGenerator = TweakPropertyCodeGenerator()
        let localConfigurationParser = LocalConfigurationParser()
        let localConfigurationContent = try localConfigurationParser.loadConfiguration(localConfigurationFilePath)
        
        let content = codeGenerator.generateConstants(localConfigurationFilename: localConfigurationFilename,
                                                      className: className,
                                                      localConfigurationContent: localConfigurationContent)
        
        let testContentPath = bundle.path(forResource: "GeneratedConfigurationAccessor+ConstantsContent", ofType: "")!
        let testContent = try String(contentsOfFile: testContentPath, encoding: .utf8).trimmingCharacters(in: .newlines)
        
        XCTAssertEqual(content, testContent)
    }
    
    func test_generateAccessor_output() throws {
        let bundle = Bundle(for: type(of: self))
        let localConfigurationFilename = "ValidConfiguration"
        let localConfigurationFilePath = bundle.path(forResource: localConfigurationFilename, ofType: "json")!
        let className = "GeneratedConfigurationAccessor"
        
        let codeGenerator = TweakPropertyCodeGenerator()
        let localConfigurationParser = LocalConfigurationParser()
        let localConfigurationContent = try localConfigurationParser.loadConfiguration(configurationFilePath: localConfigurationFilePath)
        
        let content = codeGenerator.generateAccessor(localConfigurationFilename: localConfigurationFilename,
                                                     className: className,
                                                     localConfigurationContent: localConfigurationContent)
        
        let testContentPath = bundle.path(forResource: "GeneratedConfigurationAccessorContent", ofType: "")!
        let testContent = try String(contentsOfFile: testContentPath, encoding: .utf8).trimmingCharacters(in: .newlines)
        
        XCTAssertEqual(content, testContent)
    }
}
