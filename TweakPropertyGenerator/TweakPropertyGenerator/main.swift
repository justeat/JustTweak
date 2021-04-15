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
    
    private var className: String {
        String(outputFilePath.split(separator: "/").last!.split(separator: ".").first!)
    }
    
    private var localConfigurationFilename: String {
        String(localConfigurationFilePath.split(separator: "/").last!.split(separator: ".").first!)
    }
    
    func run() throws {
        print("\(scriptName) - v\(scriptVersion)")
        
        let codeGenerator = TweakPropertyCodeGenerator()
        let localConfigurationParser = LocalConfigurationParser()
        let localConfigurationContent = try localConfigurationParser.loadConfiguration(localConfigurationFilePath)
        
        write(type: .constants,
              codeGenerator: codeGenerator,
              localConfigurationContent: localConfigurationContent,
              outputFilePath: outputFilePath)
        
        write(type: .accessor,
              codeGenerator: codeGenerator,
              localConfigurationContent: localConfigurationContent,
              outputFilePath: outputFilePath)
    }
}

extension TweakPropertyGenerator {
    
    private func write(type: TweakPropertyCodeGeneratorContentType,
                       codeGenerator: TweakPropertyCodeGenerator,
                       localConfigurationContent: Configuration,
                       outputFilePath: String) {
        
        let url = (type == .constants) ? constantsUrl(with: outputFilePath) : URL(fileURLWithPath: outputFilePath)
        
        let constants = codeGenerator.generate(type: type,
                                               localConfigurationFilename: localConfigurationFilename,
                                               className: className,
                                               localConfigurationContent: localConfigurationContent)
        try! constants.write(to: url, atomically: true, encoding: .utf8)
    }
    
    private func constantsUrl(with filePath: String) -> URL {
        let path = filePath.replacingOccurrences(of: className, with: className + "+Constants")
        return URL(fileURLWithPath: path)
    }
}

TweakPropertyGenerator.main()
