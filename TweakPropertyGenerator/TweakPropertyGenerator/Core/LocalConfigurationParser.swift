//
//  LocalConfigurationReader.swift
//  Copyright © 2021 Just Eat Takeaway. All rights reserved.
//

import Foundation

extension String: Error {}

class LocalConfigurationParser {
    
    private func type(for value: Any) -> String {
        switch value {
        case _ as String: return "String"
        case let numberValue as NSNumber: return numberValue.tweakType
        case _ as Bool: return "Bool"
        case _ as Double: return "Double"
        default: return "String"
        }
    }
    
    private func tweak(for dictionary: [String: Any], feature: FeatureKey, variable: VariableKey) -> Tweak {
        assert(dictionary["Title"] is String, "Missing 'Title' value in dictionary \(dictionary)")
        let title = dictionary["Title"] as! String
        assert(dictionary["Description"] is String, "Missing 'Description' value in dictionary \(dictionary)")
        let description = dictionary["Description"] as! String
        assert(dictionary["Group"] is String, "Missing 'Group' value in dictionary \(dictionary)")
        let group = dictionary["Group"] as! String
        assert(dictionary["Value"] != nil, "Missing 'Value' value in dictionary \(dictionary)")
        let value = dictionary["Value"]!
        return Tweak(feature: feature,
                     variable: variable,
                     title: title,
                     description: description,
                     group: group,
                     valueType: type(for: value))
    }
    
    func loadConfiguration(configurationFilePath: String) -> Configuration {
        let url = URL(fileURLWithPath: configurationFilePath)
        do {
            let data = try Data(contentsOf: url)
            guard let content = try JSONSerialization.jsonObject(with: data) as? LocalConfigurationFormat else {
                throw "Invalid format"
            }
            
            let tweaks = content.map { (featureKey: String, tweaks: [String: [String: Any]]) -> [Tweak] in
                tweaks.map { (variableKey: String, value: [String: Any]) -> Tweak in
                    tweak(for: value, feature: featureKey, variable: variableKey)
                }
            }.flatMap { $0 }
            
            let configuration = Configuration(tweaks: tweaks)
            return configuration
            
        } catch {
            print("FAILURE: Tweaks file '\(configurationFilePath)' is not valid JSON. Error: \(error)")
        }
        return Configuration(tweaks: [])
    }
}
