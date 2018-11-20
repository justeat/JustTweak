//
//  EphemeralConfiguration.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import Foundation

@objcMembers public class EphemeralConfiguration: NSObject, MutableTweaksConfiguration {
    
    private var storage = [String : TweakValue]()
    public var logClosure: TweaksLogClosure?
    
    public var priority: TweaksConfigurationPriority = .p1
    
    public var allTweakIdentifiers: [String] {
        return Array(storage.keys)
    }
    
    public func isFeatureEnabled(_ feature: String) -> Bool {
        return tweakWith(feature: "", variable: feature)?.boolValue ?? false
    }
    
    public func tweakWith(feature: String, variable: String) -> Tweak? {
        guard let storedValue = storage[variable] else { return nil }
        return Tweak(identifier: variable, title: nil, group: nil, value: storedValue, canBeDisplayed: false)
    }
    
    public func activeVariation(for experiment: String) -> String? {
        return nil
    }

    public func deleteValue(forTweakWithIdentifier identifier: String) {
        storage.removeValue(forKey: identifier)
    }
    
    public func set(boolValue value: Bool, forTweakWithIdentifier identifier: String) {
        set(numberValue: NSNumber(value: value), forTweakWithIdentifier: identifier)
    }
    
    public func set(stringValue value: String, forTweakWithIdentifier identifier: String) {
        storage[identifier] = value
    }
    
    public func set(numberValue value: NSNumber, forTweakWithIdentifier identifier: String) {
        storage[identifier] = value.tweakValue
    }    
}
