//
//  AccessorCodeGenerator.swift
//  Copyright © 2021 Just Eat Takeaway. All rights reserved.
//

import Foundation

class TweakPropertyCodeGenerator {
    
    private let featuresConst = "Features"
    private let variablesConst = "Variables"
    
    private let featureConstantsConst = "<FEATURE_CONSTANTS_CONST>"
    private let variableConstantsConst = "<VARIABLE_CONSTANTS_CONST>"
    private let classContentConst = "<CLASS_CONTENT>"
    private let tweakManagerConst = "<TWEAK_MANAGER_CONTENT>"
}

extension TweakPropertyCodeGenerator {
    
    func generateConstantsFileContent(tweaks: [Tweak],
                                      configuration: Configuration) -> String {
        let template = self.constantsTemplate(with: configuration.stackName)
        let featureConstants = self.featureConstantsCodeBlock(with: tweaks)
        let variableConstants = self.variableConstantsCodeBlock(with: tweaks)
        
        let content = template
            .replacingOccurrences(of: featureConstantsConst, with: featureConstants)
            .replacingOccurrences(of: variableConstantsConst, with: variableConstants)
        return content
    }
    
    func generateAccessorFileContent(localConfigurationFilename: String,
                                     tweaks: [Tweak],
                                     configuration: Configuration) -> String {
        let template = self.accessorTemplate(with: configuration.stackName)
        let tweakManager = self.tweakManagerCodeBlock(with: configuration)
        let classContent = self.classContent(with: tweaks)
        
        let content = template
            .replacingOccurrences(of: tweakManagerConst, with: tweakManager)
            .replacingOccurrences(of: classContentConst, with: classContent)
        return content
    }
    
    func constantsTemplate(with className: String) -> String {
        """
        //
        //  \(className)+Constants.swift
        //  Generated by TweakPropertyGenerator
        //
        
        import Foundation
        
        extension \(className) {
        
        \(featureConstantsConst)
        
        \(variableConstantsConst)
        }
        """
    }
    
    private func accessorTemplate(with className: String) -> String {
        """
        //
        //  \(className).swift
        //  Generated by TweakPropertyGenerator
        //
        
        import Foundation
        import JustTweak
        
        class \(className) {

        \(tweakManagerConst)
        
        \(classContentConst)
        }
        """
    }
    
    private func featureConstantsCodeBlock(with tweaks: [Tweak]) -> String {
        var features = Set<FeatureKey>()
        for tweak in tweaks {
            features.insert(tweak.feature)
        }
        let content: [String] = features.map {
            """
                    static let \($0.camelCased()) = "\($0)"
            """
        }
        return """
            struct \(featuresConst) {
        \(content.sorted().joined(separator: "\n"))
            }
        """
    }
    
    private func variableConstantsCodeBlock(with tweaks: [Tweak]) -> String {
        var variables = Set<VariableKey>()
        for tweak in tweaks {
            variables.insert(tweak.variable)
        }
        let content: [String] = variables.map {
            """
                    static let \($0.camelCased()) = "\($0)"
            """
        }
        return """
            struct \(variablesConst) {
        \(content.sorted().joined(separator: "\n"))
            }
        """
    }
    
    private func tweakManagerCodeBlock(with configuration: Configuration) -> String {
        let configurationsCodeBlock = self.configurationsCodeBlock(with: configuration)
        
        return """
            static let tweakManager: TweakManager = {
        \(configurationsCodeBlock)
                let tweakManager = TweakManager(configurations: configurations)
                tweakManager.useCache = \(configuration.shouldCacheTweaks)
                return tweakManager
            }()
                
            private var tweakManager: TweakManager {
                return Self.tweakManager
            }
        """
    }
    
    private func configurationsCodeBlock(with configuration: Configuration) -> String {
        let grouping = Dictionary(grouping: configuration.configurations) { $0.type }
        
        var configurationsString: [String] = [
            """
                    var configurations: [Configuration] = []\n
            """
        ]
        
        var currentIndexByConf: [String: Int] = grouping.mapValues{ _ in 0 }
        
        for configuration in configuration.configurations {
            let value = grouping[configuration.type]!
            let index = currentIndexByConf[configuration.type]!
            let configuration = value[index]
            let configurationName = "\(configuration.type.lowercaseFirstChar())_\(index+1)"
            var generatedString: [String] = []
            let macros = configuration.macros?.joined(separator: " || ")
            
            let jsonFileURL = "jsonFileURL_\(index+1)"
            let headerComment = """
                        // \(configuration.type)
                """
            generatedString.append(headerComment)
                
            if macros != nil {
                let macroStarting = """
                        #if \(macros!)
                """
                generatedString.append(macroStarting)
            }
            
            switch configuration.type {
            case "UserDefaultsConfiguration":
                let configurationAllocation =
                    """
                            let \(configurationName) = \(configuration.type)(userDefaults: \(configuration.parameter))
                            configurations.append(\(configurationName))
                    """
                generatedString.append(configurationAllocation)
                
            case "LocalConfiguration":
                let configurationAllocation =
                    """
                            let \(jsonFileURL) = Bundle.main.url(forResource: \"\(configuration.parameter)\", withExtension: "json")!
                            let \(configurationName) = \(configuration.type)(jsonURL: \(jsonFileURL))
                            configurations.append(\(configurationName))
                    """
                generatedString.append(configurationAllocation)
                
            case "CustomConfiguration":
                assert(configuration.propertyName != nil, "Missing value 'propertyName' for configuration '\(configuration)'")
                let configurationAllocation =
                    """
                            \(configuration.parameter)
                            configurations.append(\(configuration.propertyName!))
                    """
                generatedString.append(configurationAllocation)
                
            default:
                assertionFailure("Unsupported configuration \(configuration)")
                break
            }
            
            if macros != nil {
                let macroClosing = """
                        #endif
                """
                generatedString.append(macroClosing)
            }
            generatedString.append("")
            
            configurationsString.append(contentsOf: generatedString)
            currentIndexByConf[configuration.type] = currentIndexByConf[configuration.type]! + 1
        }
        
        return configurationsString.joined(separator: "\n")
    }
    
    private func classContent(with tweaks: [Tweak]) -> String {
        var content: Set<String> = []
        tweaks.forEach {
            content.insert(tweakProperty(for: $0))
        }
        return content.sorted().joined(separator: "\n\n")
    }
    
    private func tweakProperty(for tweak: Tweak) -> String {
        let propertyName = tweak.propertyName ?? tweak.variable.camelCased()
        return """
            @TweakProperty(feature: \(featuresConst).\(tweak.feature.camelCased()),
                           variable: \(variablesConst).\(tweak.variable.camelCased()),
                           tweakManager: tweakManager)
            var \(propertyName): \(tweak.valueType)
        """
    }
}