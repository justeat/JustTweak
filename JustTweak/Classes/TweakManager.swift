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
    
    public var useCache: Bool = false {
        didSet {
            if useCache != oldValue {
                resetCache()
            }
        }
    }
    
    @Atomic private var featureCache = [String : Bool]()
    @Atomic private var tweakCache = [String : [String : Tweak]]()
    @Atomic private var experimentCache = [String : String]()
    @Atomic private var observersMap = [NSObject : NSObjectProtocol]()
    
    var mutableConfiguration: MutableConfiguration? {
        return configurations.first { $0 is MutableConfiguration } as? MutableConfiguration
    }
    
    public init(configurations: [Configuration]) {
        self.configurations = configurations
        for (index, _) in self.configurations.enumerated() {
            self.configurations[index].logClosure = logClosure
        }
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(configurationDidChange), name: TweakConfigurationDidChangeNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension TweakManager: MutableConfiguration {
    
    public func isFeatureEnabled(_ feature: String) -> Bool {
        if useCache, let cachedFeature = featureCache[feature] {
            logClosure?("Feature '\(cachedFeature)' found in cache.)", .verbose)
            return cachedFeature
        }
        
        var enabled = false
        for (_, configuration) in configurations.enumerated() {
            if configuration.isFeatureEnabled(feature) {
                enabled = true
                break
            }
        }
        if useCache {
            _featureCache.mutate { $0[feature] = enabled }
        }
        return enabled
    }
    
    public func tweakWith(feature: String, variable: String) -> Tweak? {
        if useCache,
            let cachedTweaks = tweakCache[feature],
            let cachedTweak = cachedTweaks[variable] {
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
                if let _ = tweakCache[feature] {
                    _tweakCache.mutate { $0[feature]?[variable] = result }
                } else {
                    _tweakCache.mutate { $0[feature] = [variable : result] }
                }
            }
        }
        else {
            logClosure?("No Tweak found for identifier '\(variable)'", .verbose)
        }
        return result
    }
    
    public func activeVariation(for experiment: String) -> String? {
        if useCache, let cachedExperiment = experimentCache[experiment] {
            logClosure?("Experiment '\(cachedExperiment)' found in cache.)", .verbose)
            return cachedExperiment
        }
        
        var activeVariation: String? = nil
        for (_, configuration) in configurations.enumerated() {
            activeVariation = configuration.activeVariation(for: experiment)
            if activeVariation != nil { break }
        }
        if useCache {
            _experimentCache.mutate { $0[experiment] = activeVariation }
            experimentCache[experiment] = activeVariation
        }
        return activeVariation
    }
    
    public func set(_ value: TweakValue, feature: String, variable: String) {
        guard let mutableConfiguration = self.mutableConfiguration else { return }
        if useCache {
            // cannot use write-through cache because tweakWith(feature:variable:) returns a Tweak, but here we only have a TweakValue
            // we simply set the entry to nil so the next fetch will go through the list of configurations and subsequently re-cache
            _tweakCache.mutate { $0[feature]?[variable] = nil }
        }
        mutableConfiguration.set(value, feature: feature, variable: variable)
    }
    
    public func deleteValue(feature: String, variable: String) {
        guard let mutableConfiguration = self.mutableConfiguration else { return }
        if useCache {
            _tweakCache.mutate { $0[feature]?[variable] = nil }
        }
        mutableConfiguration.deleteValue(feature: feature, variable: variable)
    }
}

extension TweakManager {
    
    public func registerForConfigurationsUpdates(_ object: NSObject, closure: @escaping (Tweak) -> Void) {
        deregisterFromConfigurationsUpdates(object)
        let queue = OperationQueue.main
        let name = TweakConfigurationDidChangeNotification
        let notificationsCenter = NotificationCenter.default
        let observer = notificationsCenter.addObserver(forName: name, object: nil, queue: queue) { notification in
            guard let tweak = notification.userInfo?[TweakConfigurationDidChangeNotificationTweakKey] as? Tweak else { return }
            closure(tweak)
        }
        _observersMap.mutate { $0[object] = observer }
    }
    
    public func deregisterFromConfigurationsUpdates(_ object: NSObject) {
        guard let observer = observersMap[object] else { return }
        NotificationCenter.default.removeObserver(observer)
        _observersMap.mutate { $0.removeValue(forKey: object) }
    }
    
    @objc private func configurationDidChange() {
        if useCache {
            resetCache()
        }
    }
}

extension TweakManager {
    
    public func resetCache() {
        _featureCache.mutate { $0.removeAll() }
        _tweakCache.mutate { $0.removeAll() }
        _experimentCache.mutate { $0.removeAll() }
    }
}
