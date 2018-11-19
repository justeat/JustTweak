//
//  OptimizelyTweaksConfiguration.swift
//  Copyright (c) 2018 Just Eat Holding Ltd. All rights reserved.
//

import JustTweak
import OptimizelySDKiOS

public class OptimizelyTweaksConfiguration: NSObject, TweaksConfiguration {
    
    public var logClosure: TweaksLogClosure?
    public var priority: TweaksConfigurationPriority = .p8
    
    private var optimizelyManager: OPTLYManager?
    private var optimizelyClient: OPTLYClient?
    
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
        return optimizelyClient?.isFeatureEnabled(feature, userId: nil, attributes: nil) ?? false
    }
    
    public func tweakWith(feature: String, variable: String) -> Tweak? {
        guard let optimizelyClient = optimizelyClient, optimizelyClient.isFeatureEnabled(feature, userId: nil, attributes: nil) == true else { return nil }
        
        let tweakValue: TweakValue? = {
            if let boolValue = optimizelyClient.getFeatureVariableBoolean(feature, variableKey: variable, userId: nil, attributes: nil)?.boolValue {
                return boolValue
            }
            else if let doubleValue = optimizelyClient.getFeatureVariableDouble(feature, variableKey: variable, userId: nil, attributes: nil)?.doubleValue {
                return doubleValue
            }
            else if let intValue = optimizelyClient.getFeatureVariableInteger(feature, variableKey: variable, userId: nil, attributes: nil)?.intValue {
                return intValue
            }
            else if let stringValue = optimizelyClient.getFeatureVariableString(feature, variableKey: variable, userId: nil, attributes: nil) {
                return stringValue
            }
            return nil
        }()
        
        if let tweakValue = tweakValue {
            return Tweak(identifier: variable, title: nil, group: nil, value: tweakValue, canBeDisplayed: false)
        }
        
        return nil
    }
}
