//
//  LocalConfigurationReader.swift
//  Copyright © 2021 Just Eat Takeaway. All rights reserved.
//

import Foundation

extension String: Error {}

class LocalConfigurationParser {
    
    func loadConfiguration(configurationFilePath: String) throws -> Configuration {
        let url = URL(fileURLWithPath: configurationFilePath)
        let data = try Data(contentsOf: url)
        let content = try JSONSerialization.jsonObject(with: data) as! LocalConfigurationFormat
        
        let tweaks = try content.map { (featureKey: String, tweaks: [String: [String: Any]]) throws -> [Tweak] in
            try tweaks.map { (variableKey: String, value: [String: Any]) throws -> Tweak in
                try tweak(for: value, feature: featureKey, variable: variableKey)
            }
            .sorted {
                $0.variable < $1.variable
            }
        }
        .flatMap { $0 }
        .sorted {
            $0.feature < $1.feature
        }
        
        let configuration = Configuration(tweaks: tweaks)
        return configuration
    }
    
    func type(for value: Any) -> String {
        switch value {
        case _ as String: return "String"
        case let numberValue as NSNumber: return numberValue.tweakType
        case _ as Bool: return "Bool"
        case _ as Double: return "Double"
        default: return "unkwown"
        }
    }
    
    func tweak(for dictionary: [String: Any], feature: FeatureKey, variable: VariableKey) throws -> Tweak {
        guard let title = dictionary["Title"] as? String else {
            throw "Missing 'Title' value in dictionary \(dictionary)"
        }
        guard let description = dictionary["Description"] as? String else {
            throw "Missing 'Description' value in dictionary \(dictionary)"
        }
        guard let group = dictionary["Group"] as? String else {
            throw "Missing 'Group' value in dictionary \(dictionary)"
        }
        guard let value = dictionary["Value"] else {
            throw "Missing 'Value' value in dictionary \(dictionary)"
        }
        return Tweak(feature: feature,
                     variable: variable,
                     title: title,
                     description: description,
                     group: group,
                     valueType: type(for: value))
    }
}
