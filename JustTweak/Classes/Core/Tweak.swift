//
//  Tweak.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import Foundation

final public class Tweak: NSObject {
    
    public let identifier: String
    public let value: TweakValue
    
    public let title: String?
    public let group: String?
    
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
                    "identifier": identifier]
        }
    }
    public override var description: String {
        get {
            return dictionaryValue.description
        }
    }
    
    public init(identifier: String, title: String?, group: String?, value: TweakValue) {
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
            lhs.group == rhs.group
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
    
    convenience init(identifier: String, boolValue: Bool) {
        self.init(identifier: identifier, title: nil, group: nil, value: boolValue)
    }
    
    convenience init(identifier: String, stringValue: String) {
        self.init(identifier: identifier, title: nil, group: nil, value: stringValue)
    }
    
    convenience init(identifier: String, numberValue: NSNumber) {
        self.init(identifier: identifier, title: nil, group: nil, value: numberValue.tweakValue)
    }
}
