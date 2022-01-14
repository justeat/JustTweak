//
//  LocalTweakProvider.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import Foundation

final public class LocalTweakProvider {
    
    private enum EncodingKeys : String {
        case Title, Description, Group, Value, Encrypted
    }
    
    private let configurationFile: [String : [String : [String : AnyObject]]]
    private let fileURL: URL
    
    public var logClosure: LogClosure?
    public var decryptionClosure: ((Tweak) -> AnyTweakValue)?
    
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
    
    private func tweakValueFromJSONObject(_ jsonObject: AnyObject?) -> AnyTweakValue {
        let value: AnyTweakValue
        if let numberValue = jsonObject as? NSNumber {
            value = numberValue.tweakValue
        }
        else if let stringValue = jsonObject as? String {
            value = stringValue.eraseToAnyTweakValue()
        }
        else {
            value = false.eraseToAnyTweakValue()
        }
        return value
    }
}

extension LocalTweakProvider: TweakProvider {
    
    public func isFeatureEnabled(_ feature: String) -> Bool {
        return configurationFile[feature] != nil
    }
    
    public func tweakWith(feature: String, variable: String) throws -> Tweak {
        guard let entry = configurationFile[feature]?[variable] else { throw TweakError.notFound }
        let title = entry[EncodingKeys.Title.rawValue] as? String
        let description = entry[EncodingKeys.Description.rawValue] as? String
        let group = entry[EncodingKeys.Group.rawValue] as? String
        let value = tweakValueFromJSONObject(entry[EncodingKeys.Value.rawValue])
        let isEncrypted = (entry[EncodingKeys.Encrypted.rawValue] as? Bool) ?? false
        
        let tweak = Tweak(feature: feature,
                          variable: variable,
                          value: value,
                          title: title,
                          description: description,
                          group: group)
        
        if isEncrypted {
            guard let decryptionClosure = decryptionClosure else {
                // The configuration is not correct, it's encrypted, but there's no way to decrypt
                throw TweakError.decryptionClosureNotProvided
            }
            
            return tweak.mutatedCopy(value: decryptionClosure(tweak))
        } else {
            return tweak
        }
    }
}
