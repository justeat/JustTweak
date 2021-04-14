//
//  TweakValue+ValueTypes.swift
//  Copyright © 2021 Just Eat Takeaway. All rights reserved.
//

import Foundation

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
