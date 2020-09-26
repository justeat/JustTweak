//
//  Tweak.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import Foundation

public struct Tweak {
    
    public let feature: String
    public let variable: String
    
    public let value: TweakValue
    
    public let title: String?
    public let desc: String?
    public let group: String?
    public let source: String?

    public var displayTitle: String {
        return title ?? "\(feature):\(variable)"
    }
    
    private var dictionaryValue: [String : Any?] {
        get {
            return ["feature": feature,
                    "variable": variable,
                    "value": value,
                    "title": title,
                    "description": desc,
                    "group": group,
                    "source": source
            ]
        }
    }
    
    public init(feature: String, variable: String, value: TweakValue, title: String? = nil, description: String? = nil, group: String? = nil, source: String? = nil) {
        self.feature = feature
        self.variable = variable
        self.value = value
        self.title = title
        self.desc = description
        self.group = group
        self.source = source
    }
}

extension Tweak: CustomStringConvertible {
    
    public var description: String {
        get {
            return dictionaryValue.description
        }
    }
}

extension Tweak: Equatable {

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.feature == rhs.feature &&
            lhs.variable == rhs.variable &&
            lhs.value == rhs.value &&
            lhs.title == rhs.title &&
            lhs.desc == rhs.desc &&
            lhs.group == rhs.group &&
            lhs.source == rhs.source
    }
}

public extension Tweak {
    
    var intValue: Int {
        return value.intValue
    }
    
    var floatValue: Float {
        return value.floatValue
    }
    
    var doubleValue: Double {
        return value.doubleValue
    }
    
    var boolValue: Bool {
        return value.boolValue
    }
    
    var stringValue: String? {
        return value.stringValue
    }
}
