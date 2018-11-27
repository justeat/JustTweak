//
//  TweaksConfigurationsCoordinator.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import Foundation

final public class TweaksConfigurationsCoordinator: NSObject, TweaksConfiguration {
    
    public var logClosure: TweaksLogClosure? = {(message, logLevel) in print(message) } {
        didSet {
            for (index, _) in configurations.enumerated() {
                configurations[index].logClosure = logClosure
            }
        }
    }
    
    private var configurations: [TweaksConfiguration]
    private var tweaksCache = [String : [String : Tweak]]()
    private var observersMap = [NSObject : NSObjectProtocol]()
    
    public init(configurations: [TweaksConfiguration]) {
        self.configurations = configurations
        super.init()
        for (index, _) in self.configurations.enumerated() {
            self.configurations[index].logClosure = logClosure
        }
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(resetCache), name: TweaksConfigurationDidChangeNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func isFeatureEnabled(_ feature: String) -> Bool {
        var enabled = false
        for (_, configuration) in configurations.enumerated().reversed() {
            if configuration.isFeatureEnabled(feature) {
                enabled = true
                break
            }
        }
        return enabled
    }
    
    public func tweakWith(feature: String, variable: String) -> Tweak? {
        if let cachedTweaks = tweaksCache[feature], let cachedTweak = cachedTweaks[variable] {
            logClosure?("Tweak '\(cachedTweak)' found in cache.)", .verbose)
            return cachedTweak
        }
        
        var result: Tweak? = nil
        for (_, configuration) in configurations.enumerated().reversed() {
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
            if let _ = tweaksCache[feature] {
                tweaksCache[feature]?[variable] = result
            } else {
                tweaksCache[feature] = [variable : result]
            }
        }
        else {
            logClosure?("No Tweak found for identifier '\(variable)'", .error)
        }
        return result
    }
    
    public func activeVariation(for experiment: String) -> String? {
        var activeVariation: String? = nil
        for (_, configuration) in configurations.enumerated().reversed() {
            activeVariation = configuration.activeVariation(for: experiment)
            if activeVariation != nil { break }
        }
        return activeVariation
    }
    
    public func valueForTweakWith(feature: String, variable: String) -> TweakValue? {
        return tweakWith(feature: feature, variable: variable)?.value
    }
    
    public func topCustomizableConfiguration() -> MutableTweaksConfiguration? {
        for configuration in configurations {
            if let configuration = configuration as? MutableTweaksConfiguration {
                return configuration
            }
        }
        return nil
    }
    
    public func displayableTweaks() -> [Tweak] {
        var tweaks = [Tweak]()
        if let features = jsonConfiguration?.features {
            for (feature, variables) in features {
                for variable in variables {
                    if let tweak = tweakWith(feature: feature, variable: variable) {
                        let jsonTweak = jsonConfiguration?.tweakWith(feature: feature, variable: variable)
                        let aggregatedTweak = Tweak(feature: feature,
                                                    variable: variable,
                                                    value: tweak.value,
                                                    title: jsonTweak?.title,
                                                    description: jsonTweak?.desc,
                                                    group: jsonTweak?.group)
                        tweaks.append(aggregatedTweak)
                    }
                }
            }
        }
        return tweaks
    }
    
    public func registerForConfigurationsUpdates(_ object: NSObject, closure: @escaping () -> Void) {
        deregisterFromConfigurationsUpdates(object)
        let queue = OperationQueue.main
        let name = TweaksConfigurationDidChangeNotification
        let notificationsCenter = NotificationCenter.default
        let observer = notificationsCenter.addObserver(forName: name, object: nil, queue: queue) { (_) in
            closure()
        }
        observersMap[object] = observer
    }
    
    public func deregisterFromConfigurationsUpdates(_ object: NSObject) {
        guard let observer = observersMap[object] else { return }
        NotificationCenter.default.removeObserver(observer)
        observersMap.removeValue(forKey: object)
    }
    
    @objc public func resetCache() {
        tweaksCache = [String : [String : Tweak]]()
    }
    
    private var jsonConfiguration: JSONTweaksConfiguration? {
        return configurations.filter { $0 is JSONTweaksConfiguration }.first as? JSONTweaksConfiguration
    }
}
