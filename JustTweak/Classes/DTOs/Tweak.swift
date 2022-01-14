//
//  Tweak.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import Foundation

public struct Tweak: Hashable {
    
    public let feature: String
    public let variable: String
    
    public let value: AnyTweakValue
    
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
    
    public init(feature: String,
                variable: String,
                value: AnyTweakValue,
                title: String? = nil,
                description: String? = nil,
                group: String? = nil,
                source: String? = nil) {
        self.feature = feature
        self.variable = variable
        self.value = value
        self.title = title
        self.desc = description
        self.group = group
        self.source = source
    }
    
    func mutatedCopy(feature: String? = nil,
                     variable: String? = nil,
                     value: AnyTweakValue? = nil,
                     title: String? = nil,
                     description: String? = nil,
                     group: String? = nil,
                     source: String? = nil) -> Self {
        Self(feature: feature ?? self.feature,
             variable: variable ?? self.variable,
             value: value ?? self.value,
             title: title ?? self.title,
             description: description ?? self.desc,
             group: group ?? self.group,
             source: source ?? self.source)
    }
}

extension Tweak: CustomStringConvertible {
    
    public var description: String {
        get {
            return dictionaryValue.description
        }
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
