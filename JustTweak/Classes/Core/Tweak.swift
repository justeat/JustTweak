//
//  Tweak.swift
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
    
    public var intValue: Int {
        return Int(doubleValue)
    }
    
    public var floatValue: Float {
        return Float(doubleValue)
    }
    
    public var doubleValue: Double {
        return Double(description) ?? 0.0
    }
    
    public var boolValue: Bool {
        return self as? Bool ?? false
    }
    
    public var stringValue: String? {
        return self as? String
    }
    
}

public func ==(lhs: TweakValue, rhs: TweakValue) -> Bool {
    if let lhs = lhs as? String, let rhs = rhs as? String {
        return lhs == rhs
    }
    return NSNumber(tweakValue: lhs) == NSNumber(tweakValue: rhs)
}

@objcMembers final public class Tweak: NSObject {
    
    public let identifier: String
    public let value: TweakValue
    
    public let title: String?
    public let group: String?
    public let canBeDisplayed: Bool
    
    public var displayTitle: String {
        return title ?? identifier
    }
    
    public override var hash: Int {
        return hashValue
    }
    public override var hashValue: Int {
        return identifier.hashValue
    }
    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Tweak else { return false }
        return self == other
    }
    
    private var dictionaryValue: [String : Any?] {
        get {
            return ["title": title,
                    "group": group,
                    "value": value,
                    "identifier": identifier,
                    "canBeDisplayed": canBeDisplayed]
        }
    }
    public override var description: String {
        get {
            return dictionaryValue.description
        }
    }
    
    public init(identifier: String, title: String?, group: String?, value: TweakValue, canBeDisplayed: Bool) {
        self.canBeDisplayed = canBeDisplayed
        self.identifier = identifier
        self.value = value
        self.title = title
        self.group = group
        super.init()
    }
    
    public static func ==(lhs: Tweak, rhs: Tweak) -> Bool {
        return lhs.identifier == rhs.identifier &&
            lhs.value == rhs.value &&
            lhs.title == rhs.title &&
            lhs.group == rhs.group &&
            lhs.canBeDisplayed == rhs.canBeDisplayed
    }
    
}

// Objective-C support
public extension Tweak {
    @objc public var intValue: Int {
        return value.intValue
    }
    
    @objc public var floatValue: Float {
        return value.floatValue
    }
    
    @objc public var doubleValue: Double {
        return value.doubleValue
    }
    
    @objc public var boolValue: Bool {
        return value.boolValue
    }
    
    @objc public var stringValue: String? {
        return value.stringValue
    }
    
    convenience init(identifier: String, boolValue: Bool) {
        self.init(identifier: identifier, title: nil, group: nil, value: boolValue, canBeDisplayed: false)
    }
    
    convenience init(identifier: String, stringValue: String) {
        self.init(identifier: identifier, title: nil, group: nil, value: stringValue, canBeDisplayed: false)
    }
    
    convenience init(identifier: String, numberValue: NSNumber) {
        self.init(identifier: identifier, title: nil, group: nil, value: numberValue.tweakValue, canBeDisplayed: false)
    }
}
