//
//  FeatureFlagPropertyWrapper.swift
//  APIClient
//
//  Created by Alberto De Bortoli on 20/10/2019.
//  Copyright © 2019 Just Eat. All rights reserved.
//

import Foundation

@propertyWrapper
public struct FeatureFlag<T: TweakValue> {
    let fallbackValue: T
    let feature: String
    let variable: String
    let coordinator: TweaksConfigurationsCoordinator
    
    public init(fallbackValue: T, feature: String, variable: String, coordinator: TweaksConfigurationsCoordinator) {
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
            let configuration = coordinator.topCustomizableConfiguration()!
            configuration.set(newValue, feature: feature, variable: variable)
        }
    }
}

@propertyWrapper
public struct FeatureFlagWrappingOptional<T: TweakValue> {
    let fallbackValue: T?
    let feature: String
    let variable: String
    let coordinator: TweaksConfigurationsCoordinator
    
    public init(fallbackValue: T?, feature: String, variable: String, coordinator: TweaksConfigurationsCoordinator) {
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
            let configuration = coordinator.topCustomizableConfiguration()!
            if let newValue = newValue {
                configuration.set(newValue, feature: feature, variable: variable)
            }
            else {
                configuration.deleteValue(feature: feature, variable: variable)
            }
        }
    }
}
