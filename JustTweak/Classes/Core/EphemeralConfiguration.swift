//
//  EphemeralConfiguration.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import Foundation

public class EphemeralConfiguration: NSObject, MutableTweaksConfiguration {
    
    private var storage = [String : [String : TweakValue]]()
    public var logClosure: TweaksLogClosure?
        
    public func isFeatureEnabled(_ feature: String) -> Bool {
        return false
    }
    
    public func tweakWith(feature: String, variable: String) -> Tweak? {
        guard let storedValue = storage[feature]?[variable] else { return nil }
        return Tweak(feature: feature, variable: variable, value: storedValue, title: nil, group: nil)
    }
    
    public func activeVariation(for experiment: String) -> String? {
        return nil
    }

    public func deleteValue(feature: String, variable: String) {
        storage[feature]?.removeValue(forKey: variable)
    }
    
    public func set(_ value: Bool, feature: String, variable: String) {
        storage[feature]?[variable] = NSNumber(value: value).tweakValue
    }
    
    public func set(_ value: String, feature: String, variable: String) {
        storage[feature]?[variable] = value
    }
    
    public func set(_ value: NSNumber, feature: String, variable: String) {
        storage[feature]?[variable] = value.tweakValue
    }
}
