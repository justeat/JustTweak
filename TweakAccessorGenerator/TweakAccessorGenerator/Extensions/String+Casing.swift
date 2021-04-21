//
//  String+Casing.swift
//  Copyright © 2021 Just Eat Takeaway. All rights reserved.
//

import Foundation

extension String {
    
    func camelCased(with separator: Character = "_") -> String {
        self
            .split(separator: separator)
            .enumerated()
            .map { $0.offset == 0 ? String($0.element).lowercasedFirstChar() : String($0.element).capitalisedFirstChar() }
            .joined()
    }
    
    func lowercasedFirstChar() -> String {
        prefix(1).lowercased() + self.dropFirst()
    }
    
    func capitalisedFirstChar() -> String {
        prefix(1).uppercased() + self.dropFirst()
    }
}
