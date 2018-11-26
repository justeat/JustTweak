//
//  UserDefaultsTweaksConfiguration.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import Foundation

final public class UserDefaultsTweaksConfiguration: NSObject, MutableTweaksConfiguration {
    
    private let userDefaults: UserDefaults
    private var registeredTweaksIdentifiers: Set<String> = Set<String>()
    
    private static let userDefaultsKeyPrefix = "lib.fragments.userDefaultsKey"
    
    public var logClosure: TweaksLogClosure?
    public let priority: TweaksConfigurationPriority = .p10
    
    public init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    public func isFeatureEnabled(_ feature: String) -> Bool {
        return false
    }

    public func tweakWith(feature: String, variable: String) -> Tweak? {
        let identifier = [feature, variable].joined(separator: "-")
        let userDefaultsKey = userDefaultsKeyForTweakWithIdentifier(identifier)
        let userDefaultsValue = userDefaults.object(forKey: userDefaultsKey)
        guard let value = tweakValueFromUserDefaultsObject(userDefaultsValue as AnyObject?) else { return nil }
        return Tweak(identifier: identifier,
                     title: nil,
                     group: nil,
                     value: value)
    }
    
    public func activeVariation(for experiment: String) -> String? {
        return nil
    }

    public func deleteValue(feature: String, variable: String) {
        let identifier = [feature, variable].joined(separator: "-")
        userDefaults.removeObject(forKey: userDefaultsKeyForTweakWithIdentifier(identifier))
    }
    
    public func set(_ value: Bool, feature: String, variable: String) {
        updateUserDefaultsWith(value: value, feature: feature, variable: variable)
    }
    
    public func set(_ value: String, feature: String, variable: String) {
        updateUserDefaultsWith(value: value, feature: feature, variable: variable)
    }
    
    public func set(_ value: NSNumber, feature: String, variable: String) {
        updateUserDefaultsWith(value: value, feature: feature, variable: variable)
    }
    
    private func updateUserDefaultsWith(value: Any, feature: String, variable: String) {
        let identifier = [feature, variable].joined(separator: "-")
        registeredTweaksIdentifiers.insert(identifier)
        userDefaults.set(value, forKey: userDefaultsKeyForTweakWithIdentifier(identifier))
        userDefaults.synchronize()
        let notificationCenter = NotificationCenter.default
        let userInfo = [TweaksConfigurationDidChangeNotificationTweakIdentifierKey: identifier]
        notificationCenter.post(name: TweaksConfigurationDidChangeNotification,
                                object: self,
                                userInfo: userInfo)
    }
    
    private func userDefaultsKeyForTweakWithIdentifier(_ identifier: String) -> String {
        return "\(UserDefaultsTweaksConfiguration.userDefaultsKeyPrefix).\(identifier)"
    }
    
    private func tweakValueFromUserDefaultsObject(_ object: AnyObject?) -> TweakValue? {
        if let object = object as? String {
            return object
        }
        else if let object = object as? NSNumber {
            return object.tweakValue
        }
        return nil
    }
}
