//
//  main.swift
//  TweakPropertyGenerator
//
//  Created by Andrew Grant on 13/04/2021.
//

import Foundation
import ArgumentParser

let scriptName = "TweaksGenerator"
let scriptVersion = "1.1"

public protocol TweakValue: CustomStringConvertible {}

extension Bool: TweakValue {}
extension Int: TweakValue {}
extension Float: TweakValue {}
extension Double: TweakValue {}
extension String: TweakValue {}

public extension TweakValue {
    
    var intValue: Int {
        return Int(doubleValue)
    }
    
    var floatValue: Float {
        return Float(doubleValue)
    }
    
    var doubleValue: Double {
        return Double(description) ?? 0.0
    }
    
    var boolValue: Bool {
        return self as? Bool ?? false
    }
    
    var stringValue: String? {
        return self as? String
    }
}

public func ==(lhs: TweakValue, rhs: TweakValue) -> Bool {
    if let lhs = lhs as? String, let rhs = rhs as? String {
        return lhs == rhs
    }
    return NSNumber(tweakValue: lhs) == NSNumber(tweakValue: rhs)
}

public extension NSNumber {
    
    var tweakType: String {
        let encoding = String(cString: self.objCType)
        switch encoding {
        case "d":
            return "Double"
                
        case "q":
            return "Int"
            
        case "f":
            return "Float"
            
        case "c":
            return "Bool"
            
        default:
            return "unknown"
        }
    }
    
    var tweakValue: TweakValue {
        let encoding = String(cString: self.objCType)
        switch encoding {
        case "d":
            return self.doubleValue
            
        case "f":
            return self.floatValue
            
        case "c":
            return self.boolValue
            
        default:
            return self.intValue
        }
    }
    
    convenience init?(tweakValue: TweakValue) {
        if let tweakValue = tweakValue as? Bool {
            self.init(value: tweakValue as Bool)
        }
        else if let tweakValue = tweakValue as? Int {
            self.init(value: tweakValue as Int)
        }
        else if let tweakValue = tweakValue as? Float {
            self.init(value: tweakValue as Float)
        }
        else if let tweakValue = tweakValue as? Double {
            self.init(value: tweakValue as Double)
        }
        else {
            return nil
        }
    }
}

extension String {
    func escapeString() -> String {
        var newString = self.replacingOccurrences(of: "\"", with: "\"\"")
        if newString.contains(",") || newString.contains("\n") {
            newString = String(format: "\"%@\"", newString)
        }
        
        return newString
    }
}

extension String {
    
    func camelCased(with separator: Character = "_") -> String {
        self.lowercased()
            .split(separator: separator)
            .enumerated()
            .map { $0.offset > 0 ? $0.element.capitalized : $0.element.lowercased() }
            .joined()
    }
    
    func pascalCased(with separator: Character = "_") -> String {
        self.lowercased()
            .split(separator: separator)
            .map { $0.capitalized }
            .joined()
    }
}

typealias TweaksFormat = [String: [String: [String: Any]]]

extension String: Error {}

class LocalConfigurationReader {
    
    func loadTweaks(configurationFilePath: String) -> TweaksFormat {
        let url = URL(fileURLWithPath: configurationFilePath)
        do {
            let data = try Data(contentsOf: url)
            guard let content = try JSONSerialization.jsonObject(with: data) as? TweaksFormat else {
                throw "Invalid format"
            }
            return content
        } catch {
            print("FAILURE: Tweaks file '\(configurationFilePath)' is not valid JSON. Error: \(error)")
        }
        return [:]
    }
}

class AccessorCodeGenerator {
    
    private let featuresConst = "Features"
    private let variablesConst = "Variables"
    
    private let featureConstantsConst = "<FEATURE_CONSTANTS_CONST>"
    private let variableConstantsConst = "<VARIABLE_CONSTANTS_CONST>"
    private let classContentConst = "<CLASS_CONTENT>"
    private let tweakManagerConst = "<TWEAK_MANAGER_CONTENT>"
    
    func generate(localConfigurationFilename: String, className: String, localConfigurationContent: TweaksFormat) -> String {
        let enclosingContent = self.enclosingContent(className: className)
        
        let featureConstants = self.featureConstants(localConfigurationContent: localConfigurationContent)
        let variableConstants = self.variableConstants(localConfigurationContent: localConfigurationContent)
        let tweakManager = self.tweakManager(localConfigurationFilename: localConfigurationFilename)
        let classContent = self.classContent(localConfigurationContent: localConfigurationContent)
        
        let content = enclosingContent
            .replacingOccurrences(of: featureConstantsConst, with: featureConstants)
            .replacingOccurrences(of: variableConstantsConst, with: variableConstants)
            .replacingOccurrences(of: tweakManagerConst, with: tweakManager)
            .replacingOccurrences(of: classContentConst, with: classContent)
        
        return content
    }
    
    private func tweakManager(localConfigurationFilename: String) -> String {
        return """
            static let tweakManager: TweakManager = {
                let userDefaultsConfiguration = UserDefaultsConfiguration(userDefaults: UserDefaults.standard)
                
                let jsonFileURL = Bundle.main.url(forResource: "\(localConfigurationFilename)", withExtension: "json")!
                let localConfiguration = LocalConfiguration(jsonURL: jsonFileURL)
                
                let configurations: [Configuration] = [userDefaultsConfiguration, localConfiguration]
                return TweakManager(configurations: configurations)
            }()
                
            private var tweakManager: TweakManager {
                return Self.tweakManager
            }
        """
    }
    
    private func enclosingContent(className: String) -> String {
        let enclosingContent = """
        //
        //  \(className).swift
        //  Generated via JustTweak
        //
        
        import Foundation
        import JustTweak
        
        class \(className) {
        
        \(featureConstantsConst)
        
        \(variableConstantsConst)
        
        \(tweakManagerConst)
        
        \(classContentConst)
        }
        """
        return enclosingContent
    }
    
    private func type(for value: Any) -> String {
        switch value {
        case _ as String: return "String"
        case let numberValue as NSNumber: return numberValue.tweakType
        case _ as Bool: return "Bool"
        case _ as Double: return "Double"
        default: return "String"
        }
    }
    
    private func toTweakProperty(_ feature: String, _ key: String, _ tweak: [String: Any]) -> String {
        return """
            @TweakProperty(feature: \(featuresConst).\(feature.camelCased()),
                           variable: \(variablesConst).\(key.camelCased()),
                           tweakManager: tweakManager)
            var \(key.camelCased()): \(type(for: tweak["Value"]!))
        """
    }
    
    private func featureConstants(localConfigurationContent: TweaksFormat) -> String {
        var content: [String] = []
        for (feature, _) in localConfigurationContent {
            let constRow = """
                    static let \(feature.camelCased()) = "\(feature)"
            """
            content.append(constRow)
        }
        
        let featureConstants = Array(content).sorted().joined(separator: "\n")
        return """
            struct \(featuresConst) {
        \(featureConstants)
            }
        """
    }
    
    private func variableConstants(localConfigurationContent: TweaksFormat) -> String {
        var content: Set<String> = []
        for (_, variables) in localConfigurationContent {
            for (variable, _) in variables {
                let constRow = """
                        static let \(variable.camelCased()) = "\(variable)"
                """
                content.insert(constRow)
            }
        }
        
        let variableConstants = Array(content).sorted().joined(separator: "\n")
        return """
            struct \(variablesConst) {
        \(variableConstants)
            }
        """
    }
    
    private func classContent(localConfigurationContent: TweaksFormat) -> String {
        var content: [String] = []
        var properties: Set<String> = []
        for (feature, variables) in localConfigurationContent {
            for (variable, tweak) in variables {
                let key = variable.camelCased()
                if !properties.contains(key) {
                    properties.insert(key)
                    content.append(toTweakProperty(feature, variable, tweak))
                }
            }
        }
        return content.joined(separator: "\n\n")
    }
}

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
        let localConfigurationReader = LocalConfigurationReader()
        let localConfigurationContent = localConfigurationReader.loadTweaks(configurationFilePath: localConfigurationFilePath)
        
        let localConfigurationFilename = String(localConfigurationFilePath.split(separator: "/").last!.split(separator: ".").first!)
        let className = String(outputFilePath.split(separator: "/").last!.split(separator: ".").first!)
        let content = accessorCodeGenerator.generate(localConfigurationFilename: localConfigurationFilename,
                                                     className: className,
                                                     localConfigurationContent: localConfigurationContent)
        
        try! content.write(to: url, atomically: true, encoding: .utf8)
    }
}

TweakPropertyGenerator.main()
