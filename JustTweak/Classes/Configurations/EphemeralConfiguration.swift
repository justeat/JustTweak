//
//  EphemeralConfiguration.swift
//  Copyright (c) 2018 Just Eat Holding Ltd. All rights reserved.
//

import Foundation

extension NSDictionary: Configuration {
    
    public var logClosure: LogClosure? {
        get { return nil }
        set { }
    }
    
    public func isFeatureEnabled(_ feature: String) -> Bool {
        guard let storedValue = self[feature] as? Bool else { return false }
    }
    
    public func tweakWith(feature: String, variable: String) -> Tweak? {
        guard let storedValue = self[variable] else { return nil }
        var value: TweakValue? = nil
        if let theValue = storedValue as? String {
            value = theValue
        }
        else if let theValue = storedValue as? NSNumber {
            value = theValue.tweakValue
        }
        guard let finalValue = value else { return nil }
        return Tweak(feature: feature, variable: variable, value: finalValue)
    }
    
    public func activeVariation(for experiment: String) -> String? {
        return nil
    }
}

extension NSMutableDictionary: MutableConfiguration {
    
    public func set(_ value: TweakValue, feature: String, variable: String) {
        self[variable] = value
    }
    
    public func deleteValue(feature: String, variable: String) {
        removeObject(forKey: variable)
    }
}
