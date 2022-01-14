//
//  TweakValue.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import Foundation

public protocol TweakValue: Hashable, CustomStringConvertible {}

extension Bool: TweakValue {}
extension Int: TweakValue {}
extension Float: TweakValue {}
extension Double: TweakValue {}
extension String: TweakValue {}

public extension TweakValue {
    
    var intValue: Int {
        return Int(doubleValue)
    }
    
    var floatValue: Float {
        return Float(doubleValue)
    }
    
    var doubleValue: Double {
        return Double(description) ?? 0.0
    }
    
    var boolValue: Bool {
        Bool(description) ?? false
    }
    
    var stringValue: String {
        description
    }
    
    func eraseToAnyTweakValue() -> AnyTweakValue {
        AnyTweakValue(self)
    }
}

public struct AnyTweakValue: TweakValue {
    public let description: String
    public let value: AnyHashable

    public init<T: TweakValue>(_ tweakValue: T) {
        description = tweakValue.description
        value = AnyHashable(tweakValue)
    }
}
