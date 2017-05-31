//
//  FirebaseTweaksConfiguration
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import JustTweak
import FirebaseAnalytics
import FirebaseRemoteConfig

@objc(JEFirebaseTweaksConfiguration) public class FirebaseTweaksConfiguration: NSObject, TweaksConfiguration {
    
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
    public let priority: TweaksConfigurationPriority = .medium
    
    // Google dependencies
    private var configured: Bool = false
    internal lazy var firebaseAppClass: FIRApp.Type = {
        return FIRApp.self
    }()
    internal lazy var remoteConfiguration: FIRRemoteConfig = {
        return FIRRemoteConfig.remoteConfig()
    }()
    
    private func fetchTweaks() {
        guard configured else { return }
        remoteConfiguration.configSettings = FIRRemoteConfigSettings(developerModeEnabled: true)!
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
    
    public func tweakWith(identifier: String) -> Tweak? {
        guard configured else { return nil }
        let configValue = remoteConfiguration.configValue(forKey: identifier)
        guard configValue.source != .static else { return nil }
        guard let stringValue = configValue.stringValue else { return nil }
        return Tweak(identifier: identifier,
                     title: nil,
                     group: nil,
                     value: stringValue.tweakValue,
                     canBeDisplayed: false)
    }
    
}
