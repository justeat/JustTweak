//
//  TweakExtensions.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import Foundation

public extension String {
    
    var tweakValue: AnyTweakValue {
        if let bool = Bool(self.lowercased()) {
            return bool.eraseToAnyTweakValue()
        }
        else if let doubleValue = Double(self) {
            return doubleValue.eraseToAnyTweakValue()
        }
        return self.eraseToAnyTweakValue()
    }
}

public extension NSNumber {
    
    var tweakValue: AnyTweakValue {
        let encoding = String(cString: self.objCType)
        switch encoding {
        case "d":
            return self.doubleValue.eraseToAnyTweakValue()
            
        case "f":
            return self.floatValue.eraseToAnyTweakValue()
            
        case "c":
            return self.boolValue.eraseToAnyTweakValue()
            
        default:
            return self.intValue.eraseToAnyTweakValue()
        }
    }
    
    // TODO: is this actually needed?
//    convenience init?(tweakValue: TweakValue) {
//        if let tweakValue = tweakValue as? Bool {
//            self.init(value: tweakValue as Bool)
//        }
//        else if let tweakValue = tweakValue as? Int {
//            self.init(value: tweakValue as Int)
//        }
//        else if let tweakValue = tweakValue as? Float {
//            self.init(value: tweakValue as Float)
//        }
//        else if let tweakValue = tweakValue as? Double {
//            self.init(value: tweakValue as Double)
//        }
//        else {
//            return nil
//        }
//    }
}
