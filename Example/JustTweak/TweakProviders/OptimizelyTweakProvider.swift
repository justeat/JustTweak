//
//  OptimizelyTweakProvider.swift
//  Copyright (c) 2018 Just Eat Holding Ltd. All rights reserved.
//

import JustTweak
import OptimizelySDKiOS

public class OptimizelyTweakProvider: TweakProvider {
    
    private var optimizelyManager: OPTLYManager?
    private var optimizelyClient: OPTLYClient?
    
    public var logClosure: LogClosure?
    
    public var userId: String!
    public var attributes: [String : String]?
    
    public init() {
        /* DOWNLOAD THE Optimizely datafile from the Optimizely dashboard */
        optimizelyManager = OPTLYManager(builder: OPTLYManagerBuilder(block: { builder in
            guard let builder = builder,
                let filePath = Bundle.main.path(forResource: "ExampleOptimizelyDatafile", ofType: "json"),
                let fileContents = try? String.init(contentsOfFile: filePath, encoding: .utf8),
                let jsonDatafile = fileContents.data(using: .utf8) else { return }
            builder.datafile = jsonDatafile
            builder.sdkKey = "SDK_KEY_HERE"
        }))
        optimizelyManager?.initialize() { [weak self] error, client in
            guard let strongSelf = self else { return }
            switch (error, client) {
            case (nil, let client):
                strongSelf.optimizelyClient = client
                let notificationCentre = NotificationCenter.default
                notificationCentre.post(name: TweakProviderDidChangeNotification, object: strongSelf)
            case (let error, _):
                if let error = error {
                    strongSelf.logClosure?("Couldn't initialize Optimizely manager. \(error.localizedDescription)", .error)
                } else {
                    strongSelf.logClosure?("Couldn't initialize Optimizely manager", .error)
                }
            }
        }
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
}
