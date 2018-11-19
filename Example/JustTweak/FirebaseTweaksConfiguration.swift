//
//  FirebaseTweaksConfiguration
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import JustTweak
import FirebaseAnalytics
import FirebaseRemoteConfig

@objcMembers public class FirebaseTweaksConfiguration: NSObject, TweaksConfiguration {
    
    public override init() {
        super.init()
        
        /* DOWNLOAD THE GoogleService.plist from your app in the Firebase console and modify `useFirebase` to true */
        let useFirebase = false
        
        let googleServicePlistURL = Bundle.main.url(forResource: "GoogleService-Info", withExtension: "plist")
        if let _ = googleServicePlistURL, useFirebase {
            firebaseAppClass.configure()
            configured = true
            fetchTweaks()
        }
        else {
            logClosure?("\(self) couldn't find a GoogleService Plist. This is required for this configuration to function. No Tweak will be returned from queries.", .error)
        }
    }
    
    public var logClosure: TweaksLogClosure?
    public let priority: TweaksConfigurationPriority = .p5
    
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
        remoteConfiguration.configSettings = RemoteConfigSettings(developerModeEnabled: true)!
        remoteConfiguration.fetch { [weak self] (status, error) in
            if let error = error {
                print("!!! Error while fetching Firebase configuration => \(error) !!!")
            }
            else {
                self?.remoteConfiguration.activateFetched()
                let notificationCentre = NotificationCenter.default
                notificationCentre.post(name: TweaksConfigurationDidChangeNotification, object: self)
            }
        }
    }
    
    public func tweakWith(feature: String) -> Tweak? {
        return tweakWith(feature: "", variable: feature)
    }
    
    public func tweakWith(feature: String, variable: String) -> Tweak? {
        guard configured else { return nil }
        let configValue = remoteConfiguration.configValue(forKey: variable)
        guard configValue.source != .static else { return nil }
        guard let stringValue = configValue.stringValue else { return nil }
        return Tweak(identifier: variable,
                     title: nil,
                     group: nil,
                     value: stringValue.tweakValue,
                     canBeDisplayed: false)
    }
}
