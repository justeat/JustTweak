//
//  Tweak.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import Foundation

final public class Tweak: NSObject {
    
    public let feature: String
    public let variable: String
    
    public let value: TweakValue
    
    public let title: String?
    public let group: String?
    public let source: String?

    public var displayTitle: String {
        return title ?? "\(feature):\(variable)"
    }
    
    public override var hash: Int {
        return hashValue
    }
    
    public override var hashValue: Int {
        return "\(feature)\(variable)".hashValue
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Tweak else { return false }
        return self == other
    }
    
    private var dictionaryValue: [String : Any?] {
        get {
            return ["feature": feature,
                    "variable": variable,
                    "value": value,
                    "title": title,
                    "group": group,
                    "source": source
            ]
        }
    }
    public override var description: String {
        get {
            return dictionaryValue.description
        }
    }
    
    public init(feature: String, variable: String, value: TweakValue, title: String? = nil, group: String? = nil, source: String? = nil) {
        self.feature = feature
        self.variable = variable
        self.value = value
        self.title = title
        self.group = group
        self.source = source
        super.init()
    }
    
    public static func ==(lhs: Tweak, rhs: Tweak) -> Bool {
        return lhs.feature == rhs.feature &&
            lhs.variable == rhs.variable &&
            lhs.value == rhs.value &&
            lhs.title == rhs.title &&
            lhs.group == rhs.group &&
            lhs.source == rhs.source
    }
    
}

public extension Tweak {
    public var intValue: Int {
        return value.intValue
    }
    
    public var floatValue: Float {
        return value.floatValue
    }
    
    public var doubleValue: Double {
        return value.doubleValue
    }
    
    public var boolValue: Bool {
        return value.boolValue
    }
    
    public var stringValue: String? {
        return value.stringValue
    }
    
    convenience init(feature: String, variable: String, boolValue: Bool) {
        self.init(feature: feature, variable: variable, value: boolValue)
    }
    
    convenience init(feature: String, variable: String, stringValue: String) {
        self.init(feature: feature, variable: variable, value: stringValue)
    }
    
    convenience init(feature: String, variable: String, numberValue: NSNumber) {
        self.init(feature: feature, variable: variable, value: numberValue.tweakValue)
    }
}
