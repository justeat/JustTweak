//
//  TweakValue.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import Foundation

public protocol TweakValue: CustomStringConvertible {}

extension Bool: TweakValue {}
extension Int: TweakValue {}
extension Float: TweakValue {}
extension Double: TweakValue {}
extension String: TweakValue {
    public var description: String {
        get { return self }
    }
}

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
        return self as? Bool ?? false
    }
    
    var stringValue: String? {
        return self as? String
    }
    
}

public func ==(lhs: TweakValue, rhs: TweakValue) -> Bool {
    if let lhs = lhs as? String, let rhs = rhs as? String {
        return lhs == rhs
    }
    return NSNumber(tweakValue: lhs) == NSNumber(tweakValue: rhs)
}
