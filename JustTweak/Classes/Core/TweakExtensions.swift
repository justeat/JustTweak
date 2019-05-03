//
//  TweakExtensions.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import Foundation

public extension String {
    
    var tweakValue: TweakValue {
        get {
            let lowecase = lowercased()
            if lowecase == "true" || lowecase == "false" {
                return lowecase == "true"
            }
            else if let doubleValue = Double(self) {
                return doubleValue
            }
            return self
        }
    }
    
}

public extension NSNumber {
    
    var tweakValue: TweakValue {
        get {
            let encoding = String(cString: self.objCType)
            switch encoding {
            case "d", "f":
                return self.doubleValue
                
            case "c":
                return self.boolValue
                
            default:
                return self.intValue
            }
        }
    }
    
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
    
}
