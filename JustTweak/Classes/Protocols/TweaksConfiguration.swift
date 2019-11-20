//
//  TweaksConfiguration.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import Foundation

public protocol Configuration {
    
    var logClosure: LogClosure? { set get }    
    func isFeatureEnabled(_ feature: String) -> Bool
    func tweakWith(feature: String, variable: String) -> Tweak?
    func activeVariation(for experiment: String) -> String?
}

public protocol MutableConfiguration: Configuration {
    
    func deleteValue(feature: String, variable: String)
    func set(_ value: TweakValue, feature: String, variable: String)
}

public let TweaksConfigurationDidChangeNotification = Notification.Name("TweaksConfigurationDidChangeNotification")
public let TweaksConfigurationDidChangeNotificationTweakKey = "TweaksConfigurationDidChangeNotificationTweakKey"
