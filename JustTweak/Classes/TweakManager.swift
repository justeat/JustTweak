//
//  TweakManager.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import Foundation

final public class TweakManager {
    
    var configurations: [Configuration]
    
    public var logClosure: LogClosure? {
        didSet {
            for (index, _) in configurations.enumerated() {
                configurations[index].logClosure = logClosure
            }
        }
    }
    
    public var useCache: Bool = false
    
    private var tweaksCache = [String : [String : Tweak]]()
    private var observersMap = [NSObject : NSObjectProtocol]()
    
    var mutableConfiguration: MutableConfiguration? {
        return configurations.first { $0 is MutableConfiguration } as? MutableConfiguration
    }
    
    public init(configurations: [Configuration]) {
        self.configurations = configurations
        for (index, _) in self.configurations.enumerated() {
            self.configurations[index].logClosure = logClosure
        }
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(configurationDidChange), name: TweaksConfigurationDidChangeNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension TweakManager: MutableConfiguration {
    
    public func isFeatureEnabled(_ feature: String) -> Bool {
        var enabled = false
        for (_, configuration) in configurations.enumerated() {
            if configuration.isFeatureEnabled(feature) {
                enabled = true
                break
            }
        }
        return enabled
    }
    
    public func tweakWith(feature: String, variable: String) -> Tweak? {
        if useCache, let cachedTweaks = tweaksCache[feature], let cachedTweak = cachedTweaks[variable] {
            logClosure?("Tweak '\(cachedTweak)' found in cache.)", .verbose)
            return cachedTweak
        }
        
        var result: Tweak? = nil
        for (_, configuration) in configurations.enumerated() {
            if let tweak = configuration.tweakWith(feature: feature, variable: variable) {
                logClosure?("Tweak '\(tweak)' found in configuration \(configuration))", .verbose)
                result = Tweak(feature: feature,
                               variable: variable,
                               value: tweak.value,
                               title: tweak.title,
                               group: tweak.group,
                               source: "\(type(of: configuration))")
                break
            }
            else {
                logClosure?("Tweak with identifier '\(variable)' NOT found in configuration \(configuration))", .verbose)
            }
        }
        if let result = result {
            logClosure?("Tweak with feature '\(feature)' and variable '\(variable)' resolved. Using '\(result)'.", .debug)
            if useCache {
                if let _ = tweaksCache[feature] {
                    tweaksCache[feature]?[variable] = result
                } else {
                    tweaksCache[feature] = [variable : result]
                }
            }
        }
        else {
            logClosure?("No Tweak found for identifier '\(variable)'", .verbose)
        }
        return result
    }
    
    public func activeVariation(for experiment: String) -> String? {
        var activeVariation: String? = nil
        for (_, configuration) in configurations.enumerated() {
            activeVariation = configuration.activeVariation(for: experiment)
            if activeVariation != nil { break }
        }
        return activeVariation
    }
    
    public func set(_ value: TweakValue, feature: String, variable: String) {
        guard var mutableConfiguration = self.mutableConfiguration else { return }
        mutableConfiguration.set(value, feature: feature, variable: variable)
    }
    
    public func deleteValue(feature: String, variable: String) {
        guard var mutableConfiguration = self.mutableConfiguration else { return }
        mutableConfiguration.deleteValue(feature: feature, variable: variable)
    }
}

extension TweakManager {
    
    public func registerForConfigurationsUpdates(_ object: NSObject, closure: @escaping (Tweak) -> Void) {
        deregisterFromConfigurationsUpdates(object)
        let queue = OperationQueue.main
        let name = TweaksConfigurationDidChangeNotification
        let notificationsCenter = NotificationCenter.default
        let observer = notificationsCenter.addObserver(forName: name, object: nil, queue: queue) { notification in
            guard let tweak = notification.userInfo?[TweaksConfigurationDidChangeNotificationTweakKey] as? Tweak else { return }
            closure(tweak)
        }
        observersMap[object] = observer
    }
    
    public func deregisterFromConfigurationsUpdates(_ object: NSObject) {
        guard let observer = observersMap[object] else { return }
        NotificationCenter.default.removeObserver(observer)
        observersMap.removeValue(forKey: object)
    }
    
    @objc private func configurationDidChange() {
        if useCache {
            resetCache()
        }
    }
    
    public func resetCache() {
        tweaksCache = [String : [String : Tweak]]()
    }
}
