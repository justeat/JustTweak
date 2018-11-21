//
//  OptimizelyTweaksConfiguration.swift
//  Copyright (c) 2018 Just Eat Holding Ltd. All rights reserved.
//

import JustTweak
import OptimizelySDKiOS

public class OptimizelyTweaksConfiguration: NSObject, TweaksConfiguration {
    
    private var optimizelyManager: OPTLYManager?
    private var optimizelyClient: OPTLYClient?
    
    public var logClosure: TweaksLogClosure?
    public var priority: TweaksConfigurationPriority = .p8
    
    public var userId: String!
    public var attributes: [String : String]?
    
    public override init() {
        super.init()
        let useOptimizely = false
        guard useOptimizely else { return }
        optimizelyManager = OPTLYManager(builder: OPTLYManagerBuilder(block: { builder in
            guard let builder = builder,
                let filePath = Bundle.main.path(forResource: "ExampleOptimizelyDatafile", ofType: "json"),
                let fileContents = try? String.init(contentsOfFile: filePath, encoding: .utf8),
                let jsonDatafile = fileContents.data(using: .utf8) else { return }
            builder.datafile = jsonDatafile
            builder.sdkKey = "SDK_KEY_HERE"
        }))
        optimizelyClient = optimizelyManager?.initialize()
    }
    
    public func isFeatureEnabled(_ feature: String) -> Bool {
        return optimizelyClient?.isFeatureEnabled(feature, userId: userId, attributes: attributes) ?? false
    }
    
    public func tweakWith(feature: String, variable: String) -> Tweak? {
        guard let optimizelyClient = optimizelyClient else { return nil }
        guard optimizelyClient.isFeatureEnabled(feature, userId: userId, attributes: attributes) == true else { return nil }
        
        let tweakValue: TweakValue? = {
            if let boolValue = optimizelyClient.getFeatureVariableBoolean(feature, variableKey: variable, userId: userId, attributes: attributes)?.boolValue {
                return boolValue
            }
            else if let doubleValue = optimizelyClient.getFeatureVariableDouble(feature, variableKey: variable, userId: userId, attributes: attributes)?.doubleValue {
                return doubleValue
            }
            else if let intValue = optimizelyClient.getFeatureVariableInteger(feature, variableKey: variable, userId: userId, attributes: attributes)?.intValue {
                return intValue
            }
            else if let stringValue = optimizelyClient.getFeatureVariableString(feature, variableKey: variable, userId: userId, attributes: attributes) {
                return stringValue
            }
            return nil
        }()
        
        if let tweakValue = tweakValue {
            return Tweak(feature: feature, variable: variable, value: tweakValue, title: nil, group: nil)
        }
        
        return nil
    }
    
    public func activeVariation(for experiment: String) -> String? {
        return optimizelyClient?.activate(experiment, userId: userId)?.variationKey
    }
}
