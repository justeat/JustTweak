//
//  TweakManager.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import Foundation

final public class TweakManager {
    
    var tweakProviders: [TweakProvider]
    
    public var logClosure: LogClosure? {
        didSet {
            for (index, _) in tweakProviders.enumerated() {
                tweakProviders[index].logClosure = logClosure
            }
        }
    }
    
    public var decryptionClosure: ((Tweak) -> TweakValue)? {
        didSet {
            for (index, _) in tweakProviders.enumerated() {
                tweakProviders[index].decryptionClosure = decryptionClosure
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
    
    private let queue = DispatchQueue(label: "com.justeat.tweakManager")
    
    private var featureCache = [String : Bool]()
    private var tweakCache = [String : [String : Tweak]]()
    private var experimentCache = [String : String]()
    private var observersMap = [NSObject : NSObjectProtocol]()
    
    var mutableTweakProvider: MutableTweakProvider? {
        return tweakProviders.first { $0 is MutableTweakProvider } as? MutableTweakProvider
    }
    
    public init(tweakProviders: [TweakProvider]) {
        self.tweakProviders = tweakProviders
        for (index, _) in self.tweakProviders.enumerated() {
            self.tweakProviders[index].logClosure = logClosure
        }
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(configurationDidChange), name: TweakProviderDidChangeNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension TweakManager: MutableTweakProvider {
    
    public func isFeatureEnabled(_ feature: String) -> Bool {
        queue.sync {
            if useCache, let cachedFeature = featureCache[feature] {
                logClosure?("Feature '\(cachedFeature)' found in cache.)", .verbose)
                return cachedFeature
            }
            
            var enabled = false
            for (_, configuration) in tweakProviders.enumerated() {
                if configuration.isFeatureEnabled(feature) {
                    enabled = true
                    break
                }
            }
            if useCache {
                featureCache[feature] = enabled
            }
            return enabled
        }
    }
    
    public func tweakWith(feature: String, variable: String) -> Tweak? {
        queue.sync {
            if useCache, let cachedTweaks = tweakCache[feature], let cachedTweak = cachedTweaks[variable] {
                logClosure?("Tweak '\(cachedTweak)' found in cache.)", .verbose)
                return cachedTweak
            }
            
            var result: Tweak? = nil
            for (_, tweakProvider) in tweakProviders.enumerated() {
                if let tweak = tweakProvider.tweakWith(feature: feature, variable: variable) {
                    logClosure?("Tweak '\(tweak)' found in configuration \(tweakProvider))", .verbose)
                    
                    result = Tweak(feature: feature,
                                   variable: variable,
                                   value: tweak.value,
                                   title: tweak.title,
                                   group: tweak.group,
                                   source: "\(type(of: tweakProvider))")
                    break
                }
                else {
                    let logMessage = "Tweak with identifier '\(variable)' in configuration \(tweakProvider)) could NOT be found or has an invalid configuration"
                    logClosure?(logMessage, .verbose)
                }
            }
            if let result = result {
                logClosure?("Tweak with feature '\(feature)' and variable '\(variable)' resolved. Using '\(result)'.", .debug)
                if useCache {
                    if let _ = tweakCache[feature] {
                        tweakCache[feature]?[variable] = result
                    } else {
                        tweakCache[feature] = [variable : result]
                    }
                }
            }
            else {
                logClosure?("No Tweak found for identifier '\(variable)'", .verbose)
            }
            return result
        }
    }

    public func set(_ value: TweakValue, feature: String, variable: String) {
        guard let mutableTweakProvider = self.mutableTweakProvider else { return }
        if useCache {
            queue.sync {
                // cannot use write-through cache because tweakWith(feature:variable:) returns a Tweak, but here we only have a TweakValue
                // we simply set the entry to nil so the next fetch will go through the list of configurations and subsequently re-cache
                tweakCache[feature]?[variable] = nil
            }
        }
        mutableTweakProvider.set(value, feature: feature, variable: variable)
    }

    public func deleteValue(feature: String, variable: String) {
        guard let mutableTweakProvider = self.mutableTweakProvider else { return }
        if useCache {
            queue.sync {
                tweakCache[feature]?[variable] = nil
            }
        }
        mutableTweakProvider.deleteValue(feature: feature, variable: variable)
    }
}

extension TweakManager {
    
    public func registerForConfigurationsUpdates(_ object: NSObject, closure: @escaping (Tweak) -> Void) {
        self.deregisterFromConfigurationsUpdates(object)
        queue.sync {
            let queue = OperationQueue.main
            let name = TweakProviderDidChangeNotification
            let notificationsCenter = NotificationCenter.default
            let observer = notificationsCenter.addObserver(forName: name, object: nil, queue: queue) { notification in
                guard let tweak = notification.userInfo?[TweakProviderDidChangeNotificationTweakKey] as? Tweak else { return }
                closure(tweak)
            }
            observersMap[object] = observer
        }
    }
    
    public func deregisterFromConfigurationsUpdates(_ object: NSObject) {
        queue.sync {
            guard let observer = observersMap[object] else { return }
            NotificationCenter.default.removeObserver(observer)
            observersMap.removeValue(forKey: object)
        }
    }
    
    @objc private func configurationDidChange() {
        if useCache {
            resetCache()
        }
    }
}

extension TweakManager {
    
    public func resetCache() {
        queue.sync {
            featureCache = [String : Bool]()
            tweakCache = [String : [String : Tweak]]()
            experimentCache = [String : String]()
        }
    }
}
