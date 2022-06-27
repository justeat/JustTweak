//
//  PropertyWrappers.swift
//  Copyright (c) 2019 Just Eat Holding Ltd. All rights reserved.
//

import Foundation

@propertyWrapper
public struct TweakProperty<T: TweakValue> {
    let feature: String
    let variable: String
    let tweakManager: TweakManager
    
    public init(feature: String, variable: String, tweakManager: TweakManager) {
        self.feature = feature
        self.variable = variable
        self.tweakManager = tweakManager
    }
    
    public var wrappedValue: T {
        get {
            let tweak = try? tweakManager.tweakWith(feature: feature, variable: variable)
            return tweak?.value as! T
        }
        set {
            tweakManager.set(newValue, feature: feature, variable: variable)
        }
    }
}

@propertyWrapper
public struct FallbackTweakProperty<T: TweakValue> {
    let fallbackValue: T
    let feature: String
    let variable: String
    let tweakManager: TweakManager
    
    public init(fallbackValue: T, feature: String, variable: String, tweakManager: TweakManager) {
        self.fallbackValue = fallbackValue
        self.feature = feature
        self.variable = variable
        self.tweakManager = tweakManager
    }
    
    public var wrappedValue: T {
        get {
            let tweak = try? tweakManager.tweakWith(feature: feature, variable: variable)
            return (tweak?.value as? T) ?? fallbackValue
        }
        set {
            tweakManager.set(newValue, feature: feature, variable: variable)
        }
    }
}

@propertyWrapper
public struct OptionalTweakProperty<T: TweakValue> {
    let fallbackValue: T?
    let feature: String
    let variable: String
    let tweakManager: TweakManager
    
    public init(fallbackValue: T?, feature: String, variable: String, tweakManager: TweakManager) {
        self.fallbackValue = fallbackValue
        self.feature = feature
        self.variable = variable
        self.tweakManager = tweakManager
    }
    
    public var wrappedValue: T? {
        get {
            let tweak = try? tweakManager.tweakWith(feature: feature, variable: variable)
            return (tweak?.value as? T) ?? fallbackValue
        }
        set {
            if let newValue = newValue {
                tweakManager.set(newValue, feature: feature, variable: variable)
            }
            else {
                tweakManager.deleteValue(feature: feature, variable: variable)
            }
        }
    }
}
