//
//  main.swift
//  Copyright © 2021 Just Eat Takeaway. All rights reserved.
//

import Foundation
import ArgumentParser

struct TweakAccessorGenerator: ParsableCommand {
    
    @Option(name: .shortAndLong, help: "The local tweaks file path.")
    var localTweaksFilePath: String
    
    @Option(name: .shortAndLong, help: "The output folder.")
    var outputFolder: String
    
    @Option(name: .shortAndLong, help: "The accessor class name.")
    var accessorClassName: String
    
    private var tweaksFilename: String {
        let url = URL(fileURLWithPath: localTweaksFilePath)
        return String(url.lastPathComponent.split(separator: ".").first!)
    }

    
    func run() throws {
        let codeGenerator = TweakAccessorCodeGenerator()
        let tweakLoader = TweakLoader()
        let tweaks = try tweakLoader.load(localTweaksFilePath)

        writeConstantsFile(codeGenerator: codeGenerator,
                           tweaks: tweaks,
                           outputFolder: outputFolder,
                           accessorClassName: accessorClassName)
        
        writeAccessorFile(codeGenerator: codeGenerator,
                          tweaks: tweaks,
                          outputFolder: outputFolder,
                          accessorClassName: accessorClassName)
    }
}

extension TweakAccessorGenerator {
    
    private func writeConstantsFile(codeGenerator: TweakAccessorCodeGenerator,
                                    tweaks: [Tweak],
                                    outputFolder: String,
                                    accessorClassName: String) {
        let fileName = "\(accessorClassName)+Constants.swift"
        let url: URL = URL(fileURLWithPath: outputFolder).appendingPathComponent(fileName)
        let constants = codeGenerator.generateConstantsFileContent(tweaks: tweaks,
                                                                   accessorClassName: accessorClassName)
        if let existingConstants = try? String(contentsOf: url, encoding: .utf8) {
            if existingConstants != constants {
                try! constants.write(to: url, atomically: true, encoding: .utf8)
            }
        } else {
            try! constants.write(to: url, atomically: true, encoding: .utf8)
        }
    }
    
    private func writeAccessorFile(codeGenerator: TweakAccessorCodeGenerator,
                                   tweaks: [Tweak],
                                   outputFolder: String,
                                   accessorClassName: String) {
        let fileName = "\(accessorClassName).swift"
        let url: URL = URL(fileURLWithPath: outputFolder).appendingPathComponent(fileName)
        let accessor = codeGenerator.generateAccessorFileContent(tweaksFilename: tweaksFilename,
                                                                 tweaks: tweaks,
                                                                 accessorClassName: accessorClassName)
        if let existingAccessor = try? String(contentsOf: url, encoding: .utf8) {
            if existingAccessor != accessor {
                try! accessor.write(to: url, atomically: true, encoding: .utf8)
            }
        } else {
            try! accessor.write(to: url, atomically: true, encoding: .utf8)
        }
    }
}

TweakAccessorGenerator.main()
