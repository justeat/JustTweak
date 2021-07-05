//
//  LocalTweakProvider.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import Foundation

final public class LocalTweakProvider {
    
    private enum EncodingKeys : String {
        case Title, Description, Group, Value
    }
    
    private let configurationFile: [String : [String : [String : AnyObject]]]
    private let fileURL: URL
    
    public var logClosure: LogClosure?
    
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
    
    public init(jsonURL: URL) {
        let data = try! Data(contentsOf: jsonURL)
        let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
        let configuration = json as! [String : [String : [String : AnyObject]]]
        configurationFile = configuration
        fileURL = jsonURL
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

extension LocalTweakProvider: TweakProvider {
    
    public func isFeatureEnabled(_ feature: String) -> Bool {
        return configurationFile[feature] != nil
    }
    
    public func tweakWith(feature: String, variable: String) -> Tweak? {
        guard let entry = configurationFile[feature]?[variable] else { return nil }
        let title = entry[EncodingKeys.Title.rawValue] as? String
        let description = entry[EncodingKeys.Description.rawValue] as? String
        let group = entry[EncodingKeys.Group.rawValue] as? String
        let value = tweakValueFromJSONObject(entry[EncodingKeys.Value.rawValue])
        return Tweak(feature: feature,
                     variable: variable,
                     value: value,
                     title: title,
                     description: description,
                     group: group)
    }
}
