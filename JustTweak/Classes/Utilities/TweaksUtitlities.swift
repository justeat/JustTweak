//
//  TweaksUtilities.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

precedencegroup ComparisonPrecedence {
    associativity: left
    higherThan: LogicalConjunctionPrecedence
}

infix operator ?!: ComparisonPrecedence
public func ?!<T>(lhs: T?, rhs: T?) -> T? {
    return lhs == nil ? rhs : lhs
}
public func ?!<T>(lhs: T?, rhs: T) -> T {
    return lhs == nil ? rhs : lhs!
}
public func ?!(lhs: Bool?, rhs: Bool?) -> Bool {
    return (lhs == nil ? rhs : lhs) ?? false
}

infix operator |||: ComparisonPrecedence
public func |||(lhs: Bool?, rhs: Bool?) -> Bool {
    if let lhs = lhs, let rhs = rhs {
        return lhs || rhs
    }
    else if let lhs = lhs {
        return lhs
    }
    return rhs ?? false
}

public enum LogLevel: Int {
    case error, debug, verbose
}
