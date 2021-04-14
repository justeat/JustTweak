//
//  String+Casing.swift
//  Copyright © 2021 Just Eat Takeaway. All rights reserved.
//

import Foundation

extension String {
    
    func camelCased(with separator: Character = "_") -> String {
        self.lowercased()
            .split(separator: separator)
            .enumerated()
            .map { $0.offset > 0 ? $0.element.capitalized : $0.element.lowercased() }
            .joined()
    }
    
    func pascalCased(with separator: Character = "_") -> String {
        self.lowercased()
            .split(separator: separator)
            .map { $0.capitalized }
            .joined()
    }
}
