//
//  EphemeralTweakProvider.swift
//  Copyright (c) 2018 Just Eat Holding Ltd. All rights reserved.
//

import Foundation

extension NSDictionary: TweakProvider {
    
    public var logClosure: LogClosure? {
        get { return nil }
        set { }
    }
    
    public var decryptionClosure: ((Tweak) -> AnyTweakValue)? {
        get {
            nil
        }
        set {}
    }
    
    public func isFeatureEnabled(_ feature: String) -> Bool {
        self[feature] as? Bool ?? false
    }
    
    public func tweakWith(feature: String, variable: String) throws -> Tweak {
        guard let storedValue = self[variable] else { throw TweakError.notFound }
        var value: AnyTweakValue? = nil
        if let theValue = storedValue as? String {
            value = theValue.eraseToAnyTweakValue()
        }
        else if let theValue = storedValue as? NSNumber {
            value = theValue.tweakValue.eraseToAnyTweakValue()
        }
        guard let finalValue = value else { throw TweakError.notSupported }
        return Tweak(feature: feature, variable: variable, value: finalValue)
    }
}

extension NSMutableDictionary: MutableTweakProvider {
    
    public func set<T: TweakValue>(_ value: T, feature: String, variable: String) {
        self[variable] = value
    }
    
    public func deleteValue(feature: String, variable: String) {
        removeObject(forKey: variable)
    }
}
