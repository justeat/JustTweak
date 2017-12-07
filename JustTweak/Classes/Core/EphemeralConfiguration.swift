//
//  EphemeralConfiguration.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import Foundation

@objcMembers public class EphemeralConfiguration: NSObject, MutableTweaksConfiguration {
    
    private var storage = [String : TweakValue]()
    public var logClosure: TweaksLogClosure?
    
    public var priority: TweaksConfigurationPriority {
        return .fallback
    }
    
    public var allTweakIdentifiers: [String] {
        return Array(storage.keys)
    }
    
    public func tweakWith(identifier: String) -> Tweak? {
        guard let storedValue = storage[identifier] else { return nil }
        return Tweak(identifier: identifier, title: nil, group: nil, value: storedValue, canBeDisplayed: false)
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
