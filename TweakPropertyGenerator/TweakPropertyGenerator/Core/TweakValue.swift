//
//  TweakValue.swift
//  Copyright © 2021 Just Eat Takeaway. All rights reserved.
//

import Foundation

public protocol TweakValue: CustomStringConvertible {}

extension Bool: TweakValue {}
extension Int: TweakValue {}
extension Float: TweakValue {}
extension Double: TweakValue {}
extension String: TweakValue {}

public func ==(lhs: TweakValue, rhs: TweakValue) -> Bool {
    if let lhs = lhs as? String, let rhs = rhs as? String {
        return lhs == rhs
    }
    return NSNumber(tweakValue: lhs) == NSNumber(tweakValue: rhs)
}
