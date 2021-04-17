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
    
    private func loadConfigurationFromJson() -> Configuration {
        let url = URL(fileURLWithPath: configurationFilePath)
        let jsonData = try! Data(contentsOf: url)
        let decodedResult = try! JSONDecoder().decode(Configuration.self, from: jsonData)
        return decodedResult
    }
    
    func run() throws {
        let codeGenerator = TweakPropertyCodeGenerator()
        let localConfigurationParser = LocalConfigurationParser()
        let tweaks = try localConfigurationParser.load(localConfigurationFilePath)
        
        let configuration = loadConfigurationFromJson()
        
        writeConstantsFile(codeGenerator: codeGenerator,
                           tweaks: tweaks,
                           outputFilePath: outputFilePath)
        
        writeAccessorFile(codeGenerator: codeGenerator,
                          tweaks: tweaks,
                          outputFilePath: outputFilePath,
                          configuration: configuration)
    }
}

extension TweakPropertyGenerator {
    
    private func writeAccessorFile(codeGenerator: TweakPropertyCodeGenerator,
                                   tweaks: [Tweak],
                                   outputFilePath: String,
                                   configuration: Configuration) {
        let url: URL = URL(fileURLWithPath: outputFilePath)
        let constants = codeGenerator.generateAccessorFileContent(localConfigurationFilename: localConfigurationFilename,
                                                                  className: className,
                                                                  tweaks: tweaks,
                                                                  configuration: configuration)
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
        let url = URL(fileURLWithPath: filePath)
        let ext = url.pathExtension
        let extensionName = "Constants"
        let newUrl = url.deletingLastPathComponent().appendingPathComponent("\(className)+\(extensionName).\(ext)")
        return newUrl
    }
}

TweakPropertyGenerator.main()
