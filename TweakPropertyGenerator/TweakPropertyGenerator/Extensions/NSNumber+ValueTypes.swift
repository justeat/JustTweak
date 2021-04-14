//
//  NSNumber+ValueTypes.swift
//  Copyright © 2021 Just Eat Takeaway. All rights reserved.
//

import Foundation

public extension NSNumber {
    
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
}
