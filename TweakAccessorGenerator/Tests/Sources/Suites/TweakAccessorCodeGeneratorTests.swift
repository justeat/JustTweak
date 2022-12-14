//
//  TweakAccessorCodeGeneratorTests.swift
//  Copyright © 2021 Just Eat Takeaway. All rights reserved.
//

import XCTest
@testable import TweakAccessorGenerator

class TweakAccessorCodeGeneratorTests: XCTestCase {
    
    private var bundle: Bundle!
    private let tweaksFilename = "ValidTweaks_LowPriority"
    private var tweaksFilePath: String!
    private let generatedClassName = "GeneratedTweakAccessor"
    private var codeGenerator: TweakAccessorCodeGenerator!
    private var tweakLoader: TweakLoader!
    private var tweaks: [Tweak]!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        bundle = Bundle.module
        tweaksFilePath = try XCTUnwrap(bundle.path(forResource: tweaksFilename, ofType: "json"))
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
        try super.tearDownWithError()
    }
    
    func test_generateConstants_output() throws {
        let accessorClassName = "GeneratedTweakAccessorContent"
        let content = codeGenerator.generateConstantsFileContent(tweaks: tweaks, accessorClassName: accessorClassName)
        let testContentPath = try XCTUnwrap(bundle.path(forResource: "GeneratedTweakAccessor+ConstantsContent", ofType: ""))
        let testContent = try String(contentsOfFile: testContentPath, encoding: .utf8)
        XCTAssertEqual(content, testContent)
    }
    
    func test_generateAccessor_output() throws {
        let accessorClassName = "GeneratedTweakAccessorContent"
        let content = codeGenerator.generateAccessorFileContent(tweaksFilename: tweaksFilename,
                                                                tweaks: tweaks,
                                                                accessorClassName: accessorClassName)
        let testContentPath = try XCTUnwrap(bundle.path(forResource: "GeneratedTweakAccessorContent", ofType: ""))
        let testContent = try String(contentsOfFile: testContentPath, encoding: .utf8)
        
        XCTAssertEqual(content, testContent)
    }
    
    private func codeBlock(for customTweakProviderFile: String) throws -> String {
        let testBundle = Bundle.module
        let filePath = try XCTUnwrap(testBundle.path(forResource: customTweakProviderFile, ofType: ""))
        return try String(contentsOfFile: filePath)
    }
}
