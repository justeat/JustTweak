//
//  TweaksConfiguration.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import Foundation

public protocol TweaksConfiguration {
    
    var logClosure: TweaksLogClosure? { set get }    
    func isFeatureEnabled(_ feature: String) -> Bool
    func tweakWith(feature: String, variable: String) -> Tweak?
    func activeVariation(for experiment: String) -> String?
}

public protocol MutableTweaksConfiguration: TweaksConfiguration {
    
    func deleteValue(feature: String, variable: String)
    func set(_ value: Bool, feature: String, variable: String)
    func set(_ value: String, feature: String, variable: String)
    func set(_ value: NSNumber, feature: String, variable: String)
}

public extension MutableTweaksConfiguration {
    
    func set(value: TweakValue, feature: String, variable: String) {
        switch value {
        case is Bool:
            self.set(value as! Bool, feature: feature, variable: variable)
        case is String:
            self.set(value as! String, feature: feature, variable: variable)
        default:
            if let value = NSNumber(tweakValue: value) {
                self.set(value, feature: feature, variable: variable)
            }
        }
    }
}

public let TweaksConfigurationDidChangeNotification = Notification.Name("TweaksConfigurationDidChangeNotification")
public let TweaksConfigurationDidChangeNotificationTweakKey = "TweaksConfigurationDidChangeNotificationTweakKey"
