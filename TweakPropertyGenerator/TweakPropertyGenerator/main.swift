//
//  main.swift
//  Copyright © 2021 Just Eat Takeaway. All rights reserved.
//

import Foundation
import ArgumentParser

let scriptName = "TweakPropertyGenerator"
let scriptVersion = "1.0"

struct TweakPropertyGenerator: ParsableCommand {

    @Option(name: .shortAndLong, help: "The local configuration file path.")
    var localConfigurationFilePath: String
    
    @Option(name: .shortAndLong, help: "The output file path.")
    var outputFilePath: String
    
    @Option(name: .shortAndLong, help: "The configuration file path.")
    var configuration: String
    
    func run() throws {
        print("\(scriptName) - v\(scriptVersion)")

        let url = URL(fileURLWithPath: outputFilePath)
        
        let accessorCodeGenerator = AccessorCodeGenerator()
        let localConfigurationParser = LocalConfigurationParser()
        let localConfigurationContent = try localConfigurationParser.loadConfiguration(localConfigurationFilePath)
        
        let localConfigurationFilename = String(localConfigurationFilePath.split(separator: "/").last!.split(separator: ".").first!)
        let className = String(outputFilePath.split(separator: "/").last!.split(separator: ".").first!)
        let content = accessorCodeGenerator.generate(localConfigurationFilename: localConfigurationFilename,
                                                     className: className,
                                                     localConfigurationContent: localConfigurationContent)
        
        try! content.write(to: url, atomically: true, encoding: .utf8)
    }
}

TweakPropertyGenerator.main()
