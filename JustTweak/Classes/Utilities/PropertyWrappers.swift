//
//  PropertyWrappers.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import Foundation

@propertyWrapper
public struct FeatureFlag<T: TweakValue> {
    let fallbackValue: T
    let feature: String
    let variable: String
    let coordinator: JustTweak
    
    public init(fallbackValue: T, feature: String, variable: String, coordinator: JustTweak) {
        self.fallbackValue = fallbackValue
        self.feature = feature
        self.variable = variable
        self.coordinator = coordinator
    }
    
    public var wrappedValue: T {
        get {
            let tweak = coordinator.tweakWith(feature: feature, variable: variable)
            return (tweak?.value as? T) ?? fallbackValue
        }
        set {
            coordinator.set(newValue, feature: feature, variable: variable)
        }
    }
}

@propertyWrapper
public struct FeatureFlagWrappingOptional<T: TweakValue> {
    let fallbackValue: T?
    let feature: String
    let variable: String
    let coordinator: JustTweak
    
    public init(fallbackValue: T?, feature: String, variable: String, coordinator: JustTweak) {
        self.fallbackValue = fallbackValue
        self.feature = feature
        self.variable = variable
        self.coordinator = coordinator
    }
    
    public var wrappedValue: T? {
        get {
            let tweak = coordinator.tweakWith(feature: feature, variable: variable)
            return (tweak?.value as? T) ?? fallbackValue
        }
        set {
            if let newValue = newValue {
                coordinator.set(newValue, feature: feature, variable: variable)
            }
            else {
                coordinator.deleteValue(feature: feature, variable: variable)
            }
        }
    }
}
