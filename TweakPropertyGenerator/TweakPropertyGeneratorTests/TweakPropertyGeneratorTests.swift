//
//  TweakPropertyGeneratorTests.swift
//  Copyright © 2021 Just Eat Takeaway. All rights reserved.
//

import XCTest

class TweakPropertyGeneratorTests: XCTestCase {
    
    func test_tweakPropertyGenerator_output() {

        let bundle = Bundle(for: type(of: self))
        let localConfigurationFilename = "ExampleConfiguration"
        let localConfigurationFilePath = bundle.path(forResource: localConfigurationFilename, ofType: "json")!
        let className = "GeneratedConfigurationAccessor"
        
        let accessorCodeGenerator = AccessorCodeGenerator()
        let localConfigurationParser = LocalConfigurationParser()
        let localConfigurationContent = localConfigurationParser.loadConfiguration(configurationFilePath: localConfigurationFilePath)
        
        let content = accessorCodeGenerator.generate(localConfigurationFilename: localConfigurationFilename,
                                                     className: className,
                                                     localConfigurationContent: localConfigurationContent)
        
        let testContentPath = bundle.path(forResource: "GeneratedConfigurationAccessorContent", ofType: "")!
        let testContent = try! String(contentsOfFile: testContentPath, encoding: .utf8).trimmingCharacters(in: .newlines)
        
        XCTAssertEqual(content, testContent)
    }
}
