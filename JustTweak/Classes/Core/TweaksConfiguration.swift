//
//  TweaksConfiguration.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import Foundation

@objc(JETweaksConfigurationPriority) public enum TweaksConfigurationPriority: Int {
    case high, medium, low, fallback
}

@objc(JETweaksConfiguration) public protocol TweaksConfiguration {
    
    var logClosure: TweaksLogClosure? { set get }
    var priority: TweaksConfigurationPriority { get }
    func tweakWith(identifier: String) -> Tweak?
    
}

@objc(JEMutableTweaksConfiguration) public protocol MutableTweaksConfiguration: TweaksConfiguration {
    
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
