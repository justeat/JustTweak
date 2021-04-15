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
    private var localConfigurationContent: Configuration!
    
    override func setUpWithError() throws {
        bundle = Bundle(for: type(of: self))
        localConfigurationFilePath = bundle.path(forResource: localConfigurationFilename, ofType: "json")!
        
        codeGenerator = TweakPropertyCodeGenerator()
        localConfigurationParser = LocalConfigurationParser()
        localConfigurationContent = try localConfigurationParser.loadConfiguration(localConfigurationFilePath)
    }
    
    override func tearDownWithError() throws {
        bundle = nil
        localConfigurationFilePath = nil
        codeGenerator = nil
        localConfigurationParser = nil
        localConfigurationContent = nil
    }
    
    func test_generateConstants_output() throws {
        let content = codeGenerator.generate(type: .constants,
                                             localConfigurationFilename: localConfigurationFilename,
                                             className: generatedClassName,
                                             localConfigurationContent: localConfigurationContent)
        
        let testContentPath = bundle.path(forResource: "GeneratedConfigurationAccessor+ConstantsContent", ofType: "")!
        let testContent = try String(contentsOfFile: testContentPath, encoding: .utf8).trimmingCharacters(in: .newlines)
        
        XCTAssertEqual(content, testContent)
    }
    
    func test_generateAccessor_output() throws {
        let content = codeGenerator.generate(type: .accessor,
                                             localConfigurationFilename: localConfigurationFilename,
                                             className: generatedClassName,
                                             localConfigurationContent: localConfigurationContent)
        
        let testContentPath = bundle.path(forResource: "GeneratedConfigurationAccessorContent", ofType: "")!
        let testContent = try String(contentsOfFile: testContentPath, encoding: .utf8).trimmingCharacters(in: .newlines)
        
        XCTAssertEqual(content, testContent)
    }
}
