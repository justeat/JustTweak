//
//  String+Escaping.swift
//  Copyright © 2021 Just Eat Takeaway. All rights reserved.
//

import Foundation

extension String {
    
    func escapeString() -> String {
        var newString = self.replacingOccurrences(of: "\"", with: "\"\"")
        if newString.contains(",") || newString.contains("\n") {
            newString = String(format: "\"%@\"", newString)
        }
        
        return newString
    }
}
