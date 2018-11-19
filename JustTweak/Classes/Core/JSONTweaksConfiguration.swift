//
//  JSONTweaksConfiguration.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import Foundation

@objcMembers final public class JSONTweaksConfiguration: NSObject, TweaksConfiguration {
    
    private enum EncodingKeys : String {
        case Title, CanBeDisplayed, Value, Group
    }
    
    private let configurationFile: [String : [String : AnyObject]]
    private let fileURL: URL
    
    public var logClosure: TweaksLogClosure?
    public let priority: TweaksConfigurationPriority = .fallback
    
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
    
    public func tweakWith(feature: String) -> Tweak? {
        guard let dictionary = configurationFile[feature] else { return nil }
        let title = dictionary[EncodingKeys.Title.rawValue] as? String
        let group = dictionary[EncodingKeys.Group.rawValue] as? String
        let value = tweakValueFromJSONObject(dictionary[EncodingKeys.Value.rawValue])
        let canBeDisplayed = dictionary[EncodingKeys.CanBeDisplayed.rawValue]?.boolValue ?? false
        return Tweak(identifier: feature,
                     title: title,
                     group: group,
                     value: value,
                     canBeDisplayed: canBeDisplayed)
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
