//
//  UserDefaultsTweaksConfiguration.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import Foundation

@objcMembers final public class UserDefaultsTweaksConfiguration: NSObject, MutableTweaksConfiguration {
    
    private let userDefaults: UserDefaults
    private let fallbackConfiguration: JSONTweaksConfiguration?
    private var registeredTweaksIdentifiers: Set<String> = Set<String>()
    
    private static let userDefaultsKeyPrefix = "lib.fragments.userDefaultsKey"
    
    public var logClosure: TweaksLogClosure?
    public let priority: TweaksConfigurationPriority = .p10
    
    public var allTweakIdentifiers: [String] {
        let fallbackConfigurationTweaks = fallbackConfiguration?.allIdentifiers ?? []
        registeredTweaksIdentifiers.formUnion(fallbackConfigurationTweaks)
        return Array(registeredTweaksIdentifiers).sorted()
    }
    
    public init(userDefaults: UserDefaults, fallbackConfiguration: JSONTweaksConfiguration? = nil) {
        self.userDefaults = userDefaults
        self.fallbackConfiguration = fallbackConfiguration
    }
    
    public func isFeatureEnabled(_ feature: String) -> Bool {
        return tweakWith(feature: "", variable: feature)?.boolValue ?? false
    }

    public func tweakWith(feature: String, variable: String) -> Tweak? {
        let userDefaultsKey = userDefaultsKeyForTweakWithIdentifier(variable)
        let fallbackTweak = fallbackConfiguration?.tweakWith(feature: feature, variable: variable)
        let userDefaultsValue = userDefaults.object(forKey: userDefaultsKey)
        guard let value = tweakValueFromUserDefaultsObject(userDefaultsValue as AnyObject?) else { return nil }
        return Tweak(identifier: variable,
                     title: fallbackTweak?.title,
                     group: fallbackTweak?.group,
                     value: value,
                     canBeDisplayed: fallbackTweak?.canBeDisplayed ?? false)
    }
    
    public func set(boolValue value: Bool, forTweakWithIdentifier identifier: String) {
        set(numberValue: NSNumber(value: value as Bool), forTweakWithIdentifier: identifier)
    }
    
    public func set(stringValue value: String, forTweakWithIdentifier identifier: String) {
        updateUserDefaultsWith(value: value as AnyObject, forTweakWithIdentifier: identifier)
    }
    
    public func set(numberValue value: NSNumber, forTweakWithIdentifier identifier: String) {
        updateUserDefaultsWith(value: value, forTweakWithIdentifier: identifier)
    }
    
    private func updateUserDefaultsWith(value: AnyObject, forTweakWithIdentifier identifier: String) {
        registeredTweaksIdentifiers.insert(identifier)
        userDefaults.set(value, forKey: userDefaultsKeyForTweakWithIdentifier(identifier))
        userDefaults.synchronize()
        let notificationCenter = NotificationCenter.default
        let userInfo = [TweaksConfigurationDidChangeNotificationTweakIdentifierKey: identifier]
        notificationCenter.post(name: TweaksConfigurationDidChangeNotification,
                                object: self,
                                userInfo: userInfo)
    }
    
    public func deleteValue(forTweakWithIdentifier identifier: String) {
        userDefaults.removeObject(forKey: userDefaultsKeyForTweakWithIdentifier(identifier))
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
