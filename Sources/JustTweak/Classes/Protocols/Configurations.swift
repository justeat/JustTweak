//
//  TweaksConfiguration.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import Foundation

public enum LogLevel: Int {
    case error, debug, verbose
}

public typealias LogClosure = (String, LogLevel) -> Void

public protocol Configuration {
    var logClosure: LogClosure? { set get }
    func isFeatureEnabled(_ feature: String) -> Bool
    func tweakWith(feature: String, variable: String) -> Tweak?
    func activeVariation(for experiment: String) -> String?
}

public protocol MutableConfiguration: Configuration {
    func set(_ value: TweakValue, feature: String, variable: String)
    func deleteValue(feature: String, variable: String)
}

public let TweakConfigurationDidChangeNotification = Notification.Name("TweakConfigurationDidChangeNotification")
public let TweakConfigurationDidChangeNotificationTweakKey = "TweakConfigurationDidChangeNotificationTweakKey"
