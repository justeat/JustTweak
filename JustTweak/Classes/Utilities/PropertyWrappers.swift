//
//  PropertyWrappers.swift
//  Copyright (c) 2019 Just Eat Holding Ltd. All rights reserved.
//

import Foundation

@propertyWrapper
public struct TweakProperty<T: TweakValue> {
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
            let tweak = tweakManager.tweakWith(feature: feature, variable: variable)
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
            let tweak = tweakManager.tweakWith(feature: feature, variable: variable)
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

@propertyWrapper
struct Atomic<Value> {

    let queue = DispatchQueue(label: "com.justeat.AtomicPropertyWrapper", attributes: .concurrent)
    var value: Value

    init(wrappedValue: Value) {
        self.value = wrappedValue
    }

    var wrappedValue: Value {
        get {
            return queue.sync { value }
        }
        set {
            queue.sync(flags: .barrier) { value = newValue }
        }
    }

    mutating func mutate(_ mutation: (inout Value) throws -> Void) rethrows {
        try queue.sync(flags: .barrier) {
            try mutation(&value)
        }
    }
}
