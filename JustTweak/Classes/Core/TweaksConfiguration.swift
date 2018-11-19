//
//  TweaksConfiguration.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import Foundation

@objc public enum TweaksConfigurationPriority: Int {
    case p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10
}

@objc public protocol TweaksConfiguration {
    
    var logClosure: TweaksLogClosure? { set get }
    var priority: TweaksConfigurationPriority { get }
    func isFeatureEnabled(_ feature: String) -> Bool
    func tweakWith(feature: String, variable: String) -> Tweak?
}

@objc public protocol MutableTweaksConfiguration: TweaksConfiguration {
    
    var allTweakIdentifiers: [String] { get }
    
    func deleteValue(forTweakWithIdentifier identifier: String)
    func set(boolValue value: Bool, forTweakWithIdentifier identifier: String)
    func set(stringValue value: String, forTweakWithIdentifier identifier: String)
    func set(numberValue value: NSNumber, forTweakWithIdentifier identifier: String)
}

public extension MutableTweaksConfiguration {
    
    func set(value: TweakValue, forTweakWithIdentifier identifier: String) {
        if let value = value as? Bool {
            set(boolValue: value, forTweakWithIdentifier: identifier)
        }
        if let value = value as? String {
            set(stringValue: value, forTweakWithIdentifier: identifier)
        }
        else if let value = NSNumber(tweakValue: value) {
            set(numberValue: value, forTweakWithIdentifier: identifier)
        }
    }
}

public let TweaksConfigurationDidChangeNotification = Notification.Name("TweaksConfigurationDidChangeNotification")
public let TweaksConfigurationDidChangeNotificationTweakIdentifierKey = "TweaksConfigurationDidChangeNotificationTweakIdentifierKey"
