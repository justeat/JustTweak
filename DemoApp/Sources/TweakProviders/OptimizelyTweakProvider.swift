////
////  OptimizelyTweakProvider.swift
////  Copyright (c) 2018 Just Eat Holding Ltd. All rights reserved.
////
//
//import JustTweak
//import Foundation
//import Optimizely
//
//public class OptimizelyTweakProvider: TweakProvider {
//
//    public var decryptionClosure: ((JustTweak.Tweak) -> JustTweak.TweakValue)?
//
//    
//   // private var optimizelyManager: OPTLYManager?
//    private var optimizelyClient: OptimizelyClient?
//    
//    public var logClosure: LogClosure?
//    
//    public var userId: String!
//    public var attributes: [String : String]?
//    
//    public init() {
//
//        guard let filePath = Bundle.main.path(forResource: "ExampleOptimizelyDatafile", ofType: "json"),
//            let fileContents = try? String.init(contentsOfFile: filePath, encoding: .utf8),
//            let jsonDatafile = fileContents.data(using: .utf8) else { return }
//
//        optimizelyClient = OptimizelyClient(sdkKey: "SDK_KEY_HERE")
//        // Instantiate a client synchronously using a given datafile
//        do {
//           try optimizelyClient?.start(datafile: jsonDatafile)
//        } catch {
//           // errors
//        }
////        /* DOWNLOAD THE Optimizely datafile from the Optimizely dashboard */
////        optimizelyClient = optimizelyClient(builder: Optimizely(block: { builder in
////            guard let builder = builder,
////                let filePath = Bundle.main.path(forResource: "ExampleOptimizelyDatafile", ofType: "json"),
////                let fileContents = try? String.init(contentsOfFile: filePath, encoding: .utf8),
////                let jsonDatafile = fileContents.data(using: .utf8) else { return }
////            builder.datafile = jsonDatafile
////            builder.sdkKey = "SDK_KEY_HERE"
////        }))
////        optimizelyManager?.initialize() { [weak self] error, client in
////            guard let strongSelf = self else { return }
////            switch (error, client) {
////            case (nil, let client):
////                strongSelf.optimizelyClient = client
////                let notificationCentre = NotificationCenter.default
////                notificationCentre.post(name: TweakProviderDidChangeNotification, object: strongSelf)
////            case (let error, _):
////                if let error = error {
////                    strongSelf.logClosure?("Couldn't initialize Optimizely manager. \(error.localizedDescription)", .error)
////                } else {
////                    strongSelf.logClosure?("Couldn't initialize Optimizely manager", .error)
////                }
////            }
////        }
//    }
//    
//    public func isFeatureEnabled(_ feature: String) -> Bool {
//        return optimizelyClient?.isFeatureEnabled(featureKey: feature, userId: userId, attributes: attributes) ?? false
//    }
//    
//    public func tweakWith(feature: String, variable: String) throws -> Tweak {
//        guard let optimizelyClient = optimizelyClient,
//              optimizelyClient.isFeatureEnabled(featureKey: feature, userId: userId, attributes: attributes) == true
//        else {
//            throw TweakError.notFound
//        }
//        
//        let tweakValue: TweakValue? = {
//            if let boolValue =
//                try? optimizelyClient.getFeatureVariableBoolean(featureKey: feature, variableKey: variable, userId: userId, attributes: attributes).boolValue {
//                return boolValue
//            }
//            else if let doubleValue = try? optimizelyClient.getFeatureVariableDouble(featureKey: feature, variableKey: variable, userId: userId, attributes: attributes).doubleValue {
//                return doubleValue
//            }
//            else if let intValue = try? optimizelyClient.getFeatureVariableInteger(featureKey: feature, variableKey: variable, userId: userId, attributes: attributes).intValue {
//                return intValue
//            }
//           else if let stringValue = try? optimizelyClient.getFeatureVariableString(featureKey: feature, variableKey: variable, userId: userId, attributes: attributes) {
//                return stringValue
//            }
//            return nil
//        }()
//
//        guard let tweakValue = tweakValue else {
//            throw TweakError.notFound
//        }
//        return Tweak(feature: feature, variable: variable, value: tweakValue, title: nil, group: nil)
//    }
//}
