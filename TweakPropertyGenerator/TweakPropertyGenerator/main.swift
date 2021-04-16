//
//  main.swift
//  Copyright © 2021 Just Eat Takeaway. All rights reserved.
//

import Foundation
import ArgumentParser

struct TweakPropertyGenerator: ParsableCommand {
    
    @Option(name: .shortAndLong, help: "The local configuration file path.")
    var localConfigurationFilePath: String
    
    @Option(name: .shortAndLong, help: "The output file path.")
    var outputFilePath: String
    
    @Option(name: .shortAndLong, help: "The configuration file path.")
    var configurationFilePath: String
    
    private var className: String {
        let url = URL(fileURLWithPath: outputFilePath)
        return String(url.lastPathComponent.split(separator: ".").first!)
    }
    
    private var localConfigurationFilename: String {
        let url = URL(fileURLWithPath: localConfigurationFilePath)
        return String(url.lastPathComponent.split(separator: ".").first!)
    }
    
    private func loadConfigurationFromJson() -> [Configuration] {
        let url = URL(fileURLWithPath: configurationFilePath)
        let jsonData = try! Data(contentsOf: url)
        let decodedResult = try! JSONDecoder().decode([Configuration].self, from: jsonData)
        return decodedResult
    }
    
    func run() throws {
        let codeGenerator = TweakPropertyCodeGenerator()
        let localConfigurationParser = LocalConfigurationParser()
        let tweaks = try localConfigurationParser.load(localConfigurationFilePath)
        
        let configurations = loadConfigurationFromJson()
        
        writeConstantsFile(codeGenerator: codeGenerator,
                           tweaks: tweaks,
                           outputFilePath: outputFilePath)
        
        writeAccessorFile(codeGenerator: codeGenerator,
                          tweaks: tweaks,
                          outputFilePath: outputFilePath,
                          configurations: configurations)
    }
}

extension TweakPropertyGenerator {
    
    private func writeAccessorFile(codeGenerator: TweakPropertyCodeGenerator,
                                   tweaks: [Tweak],
                                   outputFilePath: String,
                                   configurations: [Configuration]) {
        let url: URL = URL(fileURLWithPath: outputFilePath)
        let constants = codeGenerator.generateAccessorFileContent(localConfigurationFilename: localConfigurationFilename,
                                                                  className: className,
                                                                  tweaks: tweaks,
                                                                  configurations: configurations)
        try! constants.write(to: url, atomically: true, encoding: .utf8)
    }
    
    private func writeConstantsFile(codeGenerator: TweakPropertyCodeGenerator,
                                    tweaks: [Tweak],
                                    outputFilePath: String) {
        let url: URL = constantsUrl(with: outputFilePath)
        let constants = codeGenerator.generateConstantsFileContent(className: className,
                                                                   tweaks: tweaks)
        try! constants.write(to: url, atomically: true, encoding: .utf8)
    }
    
    private func constantsUrl(with filePath: String) -> URL {
        let path = filePath.replacingOccurrences(of: className, with: className + "+Constants")
        return URL(fileURLWithPath: path)
    }
}

TweakPropertyGenerator.main()
