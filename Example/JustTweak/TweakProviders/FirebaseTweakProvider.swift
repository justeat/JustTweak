//
//  FirebaseTweakProvider.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import JustTweak
import FirebaseCore
import FirebaseRemoteConfig

public class FirebaseTweakProvider: TweakProvider {
    
    public init() {
        /* DOWNLOAD THE GoogleService.plist from the Firebase dashboard */
        let googleServicePlistURL = Bundle.main.url(forResource: "GoogleService-Info", withExtension: "plist")
        if let _ = googleServicePlistURL {
            firebaseAppClass.configure()
            configured = true
            fetchTweaks()
        }
        else {
            logClosure?("\(self) couldn't find a GoogleService Plist. This is required for this configuration to function. No Tweak will be returned from queries.", .error)
        }
    }
    
    public var logClosure: LogClosure?
    
    // Google dependencies
    private var configured: Bool = false
    internal lazy var firebaseAppClass: FirebaseApp.Type = {
        return FirebaseApp.self
    }()
    internal lazy var remoteConfiguration: RemoteConfig = {
        return RemoteConfig.remoteConfig()
    }()
    
    private func fetchTweaks() {
        guard configured else { return }
        remoteConfiguration.configSettings = RemoteConfigSettings()
        remoteConfiguration.fetch { [weak self] (status, error) in
            guard let self = self else { return }
            if let error = error {
                self.logClosure?("Error while fetching Firebase configuration => \(error)", .error)
            }
            else {
                self.remoteConfiguration.activate(completion: nil) // You can pass a completion handler if you want the configuration to be applied immediately after being fetched; otherwise it will be applied on next launch
                let notificationCentre = NotificationCenter.default
                notificationCentre.post(name: TweakProviderDidChangeNotification, object: self)
            }
        }
    }
    
    public func isFeatureEnabled(_ feature: String) -> Bool {
        let configValue = remoteConfiguration.configValue(forKey: feature)
        guard configValue.source != .static else { return false }
        return configValue.boolValue
    }
    
    public func tweakWith(feature: String, variable: String) throws -> Tweak {
        guard configured else { throw TweakError.notFound }
        let configValue = remoteConfiguration.configValue(forKey: variable)
        guard configValue.source != .static else { return nil }
        guard let stringValue = configValue.stringValue else { return nil }
        return Tweak(feature: feature,
                     variable: variable,
                     value: stringValue.tweakValue,
                     title: nil,
                     group: nil)
    }
}
