//
//  JSONTweaksConfiguration.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import Foundation

final public class JSONTweaksConfiguration: NSObject, TweaksConfiguration {
    
    private enum EncodingKeys : String {
        case Title, Value, Group
    }
    
    private let configurationFile: [String : [String : AnyObject]]
    private let fileURL: URL
    
    public var logClosure: TweaksLogClosure?
    public let priority: TweaksConfigurationPriority = .p0
    
    public var features: [String : [String]] {
        var storage: [String : [String]] = [:]
        for identifier in allIdentifiers {
            let components = identifier.split(separator: "-")
            let feature = String(components[0])
            let variable = String(components[1])
            
            if let _ = storage[feature] {
                storage[feature]?.append(variable)
            } else {
                storage[feature] = [variable]
            }
        }
        return storage
    }
    
    public var allIdentifiers: [String] {
        return Array(configurationFile.keys)
    }
    
    public override var description: String {
        get { return "\(super.description) { fileURL: \(fileURL) }" }
    }
    
    public init?(defaultValuesFromJSONAtURL jsonURL: URL) {
        guard let data = try? Data(contentsOf: jsonURL) else { return nil }
        let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
        guard let configuration = json as? [String : [String : AnyObject]] else {
            return nil
        }
        configurationFile = configuration
        fileURL = jsonURL
    }
    
    public func isFeatureEnabled(_ feature: String) -> Bool {
        return configurationFile[feature] != nil
    }
    
    public func tweakWith(feature: String, variable: String) -> Tweak? {
        let identifier = [feature, variable].joined(separator: "-")
        guard let dictionary = configurationFile[identifier] else { return nil }
        let title = dictionary[EncodingKeys.Title.rawValue] as? String
        let group = dictionary[EncodingKeys.Group.rawValue] as? String
        let value = tweakValueFromJSONObject(dictionary[EncodingKeys.Value.rawValue])
        return Tweak(identifier: identifier,
                     title: title,
                     group: group,
                     value: value)
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
