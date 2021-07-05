//
//  TweakProvider.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import Foundation

public enum LogLevel: Int {
    case error, debug, verbose
}

public typealias LogClosure = (String, LogLevel) -> Void

public protocol TweakProvider {
    var logClosure: LogClosure? { set get }
    func isFeatureEnabled(_ feature: String) -> Bool
    func tweakWith(feature: String, variable: String) -> Tweak?
}

public protocol MutableTweakProvider: TweakProvider {
    func set(_ value: TweakValue, feature: String, variable: String)
    func deleteValue(feature: String, variable: String)
}

public let TweakProviderDidChangeNotification = Notification.Name("TweakProviderDidChangeNotification")
public let TweakProviderDidChangeNotificationTweakKey = "TweakProviderDidChangeNotificationTweakKey"
