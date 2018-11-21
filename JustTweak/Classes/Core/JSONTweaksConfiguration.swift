//
//  JSONTweaksConfiguration.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import Foundation

final public class JSONTweaksConfiguration: NSObject, TweaksConfiguration {
    
    private enum EncodingKeys : String {
        case Title, Group, Value
    }
    
    private let configurationFile: [String : [String : [String : AnyObject]]]
    private let fileURL: URL
    
    public var logClosure: TweaksLogClosure?
    public let priority: TweaksConfigurationPriority = .p0
    
    public var features: [String : [String]] {
        var storage: [String : [String]] = [:]
        for feature in Array(configurationFile.keys) {
            for variable in Array(configurationFile[feature]!.keys) {
                if let _ = storage[feature] {
                    storage[feature]?.append(variable)
                } else {
                    storage[feature] = [variable]
                }
            }
        }
        return storage
    }
    
    public override var description: String {
        get { return "\(super.description) { fileURL: \(fileURL) }" }
    }
    
    public init?(jsonURL: URL) {
        guard let data = try? Data(contentsOf: jsonURL) else { return nil }
        let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
        guard let configuration = json as? [String : [String : [String : AnyObject]]] else {
            return nil
        }
        configurationFile = configuration
        fileURL = jsonURL
    }
    
    public func isFeatureEnabled(_ feature: String) -> Bool {
        return configurationFile[feature] != nil
    }
    
    public func tweakWith(feature: String, variable: String) -> Tweak? {
        guard let entry = configurationFile[feature]?[variable] else { return nil }
        let title = entry[EncodingKeys.Title.rawValue] as? String
        let group = entry[EncodingKeys.Group.rawValue] as? String
        let value = tweakValueFromJSONObject(entry[EncodingKeys.Value.rawValue])
        return Tweak(feature: feature,
                     variable: variable,
                     value: value,
                     title: title,
                     group: group)
    }
    
    public func activeVariation(for experiment: String) -> String? {
        return nil
    }
    
    private func tweakValueFromJSONObject(_ jsonObject: AnyObject?) -> TweakValue {
        let value: TweakValue
        if let numberValue = jsonObject as? NSNumber {
            value = numberValue.tweakValue
        }
        else if let stringValue = jsonObject as? String {
            value = stringValue
        }
        else {
            value = false
        }
        return value
    }
}
