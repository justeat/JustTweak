//
//  main.swift
//  Copyright © 2021 Just Eat Takeaway. All rights reserved.
//

import Foundation
import ArgumentParser

struct TweakPropertyGenerator: ParsableCommand {
    
    @Option(name: .shortAndLong, help: "The local configuration file path.")
    var tweaksFilePath: String
    
    @Option(name: .shortAndLong, help: "The output folder.")
    var outputFolder: String
    
    @Option(name: .shortAndLong, help: "The configuration file path.")
    var configurationFilePath: String
    
    private var tweaksFilename: String {
        let url = URL(fileURLWithPath: tweaksFilePath)
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
        let localConfigurationParser = TweakParser()
        let tweaks = try localConfigurationParser.load(tweaksFilePath)
        let configuration = loadConfigurationFromJson()
        
        writeConstantsFile(codeGenerator: codeGenerator,
                           tweaks: tweaks,
                           outputFolder: outputFolder,
                           configuration: configuration)
        
        writeAccessorFile(codeGenerator: codeGenerator,
                          tweaks: tweaks,
                          outputFolder: outputFolder,
                          configuration: configuration)
    }
}

extension TweakPropertyGenerator {
    
    private func writeAccessorFile(codeGenerator: TweakPropertyCodeGenerator,
                                   tweaks: [Tweak],
                                   outputFolder: String,
                                   configuration: Configuration) {
        let fileName = "\(configuration.stackName).swift"
        let url: URL = URL(fileURLWithPath: outputFolder).appendingPathComponent(fileName)
        let constants = codeGenerator.generateAccessorFileContent(tweaksFilename: tweaksFilename,
                                                                  tweaks: tweaks,
                                                                  configuration: configuration)
        try! constants.write(to: url, atomically: true, encoding: .utf8)
    }
    
    private func writeConstantsFile(codeGenerator: TweakPropertyCodeGenerator,
                                    tweaks: [Tweak],
                                    outputFolder: String,
                                    configuration: Configuration) {
        let fileName = "\(configuration.stackName)+Constants.swift"
        let url: URL = URL(fileURLWithPath: outputFolder).appendingPathComponent(fileName)
        let constants = codeGenerator.generateConstantsFileContent(tweaks: tweaks,
                                                                   configuration: configuration)
        try! constants.write(to: url, atomically: true, encoding: .utf8)
    }
}

TweakPropertyGenerator.main()
