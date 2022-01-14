//
//  UserDefaultsTweakProvider.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import Foundation

final public class UserDefaultsTweakProvider {
    
    private let userDefaults: UserDefaults
    
    private static let userDefaultsKeyPrefix = "lib.fragments.userDefaultsKey"
    
    public var logClosure: LogClosure?
    public var decryptionClosure: ((Tweak) -> AnyTweakValue)?
    
    public init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
}

extension UserDefaultsTweakProvider: TweakProvider {
    
    public func isFeatureEnabled(_ feature: String) -> Bool {
        let userDefaultsKey = keyForTweakWithIdentifier(feature)
        return userDefaults.bool(forKey: userDefaultsKey)
    }

    public func tweakWith(feature: String, variable: String) throws -> Tweak {
        let userDefaultsKey = keyForTweakWithIdentifier(variable)
        let userDefaultsValue = userDefaults.object(forKey: userDefaultsKey) as AnyObject?
        guard let value = updateUserDefaults(userDefaultsValue) else { throw TweakError.notFound }
        
        return Tweak(
            feature: feature,
            variable: variable,
            value: value,
            title: nil,
            group: nil
        )
    }
}

extension UserDefaultsTweakProvider: MutableTweakProvider {
    public func set<T: TweakValue>(_ value: T, feature: String, variable: String) {
        updateUserDefaults(value: value, feature: feature, variable: variable)
    }

    public func deleteValue(feature: String, variable: String) {
        userDefaults.removeObject(forKey: keyForTweakWithIdentifier(variable))
    }
}

extension UserDefaultsTweakProvider {
    
    private func keyForTweakWithIdentifier(_ identifier: String) -> String {
        return "\(UserDefaultsTweakProvider.userDefaultsKeyPrefix).\(identifier)"
    }
    
    private func updateUserDefaults(_ object: AnyObject?) -> AnyTweakValue? {
        if let object = object as? String {
            return object.eraseToAnyTweakValue()
        }
        else if let object = object as? NSNumber {
            return object.tweakValue.eraseToAnyTweakValue()
        }
        return nil
    }
        
    private func updateUserDefaults<T: TweakValue>(value: T, feature: String, variable: String) {
        userDefaults.set(value, forKey: keyForTweakWithIdentifier(variable))
        DispatchQueue.main.async {
            let notificationCenter = NotificationCenter.default
            let tweak = Tweak(feature: feature, variable: variable, value: value.eraseToAnyTweakValue())
            let userInfo = [TweakProviderDidChangeNotificationTweakKey: tweak]
            notificationCenter.post(name: TweakProviderDidChangeNotification,
                                    object: self,
                                    userInfo: userInfo)
        }
    }
}
