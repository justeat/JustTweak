//
//  NSNumber+ValueTypes.swift
//  Copyright © 2021 Just Eat Takeaway. All rights reserved.
//

import Foundation

public extension NSNumber {
    
    convenience init?(tweakValue: TweakValue) {
        if let tweakValue = tweakValue as? Bool {
            self.init(value: tweakValue as Bool)
        }
        else if let tweakValue = tweakValue as? Int {
            self.init(value: tweakValue as Int)
        }
        else if let tweakValue = tweakValue as? Float {
            self.init(value: tweakValue as Float)
        }
        else if let tweakValue = tweakValue as? Double {
            self.init(value: tweakValue as Double)
        }
        else {
            return nil
        }
    }
    
    var tweakType: String {
        let encoding = String(cString: self.objCType)
        switch encoding {
        case "d":
            return "Double"
                
        case "q":
            return "Int"
            
        case "f":
            return "Float"
            
        case "c":
            return "Bool"
            
        default:
            return "unknown"
        }
    }
    
    var tweakValue: TweakValue {
        let encoding = String(cString: self.objCType)
        switch encoding {
        case "d":
            return self.doubleValue
            
        case "f":
            return self.floatValue
            
        case "c":
            return self.boolValue
            
        default:
            return self.intValue
        }
    }
}
