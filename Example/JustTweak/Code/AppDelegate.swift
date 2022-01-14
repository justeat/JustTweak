//
//  AppDelegate.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import JustTweak
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var tweakAccessor: GeneratedTweakAccessor!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let navigationController = window?.rootViewController as! UINavigationController
        let viewController = navigationController.topViewController as! ViewController
        tweakAccessor = GeneratedTweakAccessor(with: makeTweakManager())
        viewController.tweakAccessor = tweakAccessor
        viewController.tweakManager = tweakAccessor.tweakManager
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if tweakAccessor.shouldShowAlert {
            let alertController = UIAlertController(title: "Hello",
                                                    message: "Welcome to this Demo app!",
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Continue", style: .default, handler: nil))
            window?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    func makeTweakManager() -> TweakManager {
        var tweakProviders: [TweakProvider] = []

        // EphemeralTweakProvider
        #if DEBUG || CONFIGURATION_UI_TESTS
        let ephemeralTweakProvider_1 = NSMutableDictionary()
        tweakProviders.append(ephemeralTweakProvider_1)
        #endif

        // UserDefaultsTweakProvider
        #if DEBUG || CONFIGURATION_DEBUG
        let userDefaultsTweakProvider_1 = UserDefaultsTweakProvider(userDefaults: UserDefaults.standard)
        tweakProviders.append(userDefaultsTweakProvider_1)
        #endif

        // LocalTweakProvider
        #if DEBUG
        let jsonFileURL_1 = Bundle.main.url(forResource: "LocalTweaks_TopPriority_example", withExtension: "json")!
        let localTweakProvider_1 = LocalTweakProvider(jsonURL: jsonFileURL_1)
        tweakProviders.append(localTweakProvider_1)
        #endif

        // LocalTweakProvider
        let jsonFileURL_2 = Bundle.main.url(forResource: "LocalTweaks_example", withExtension: "json")!
        let localTweakProvider_2 = LocalTweakProvider(jsonURL: jsonFileURL_2)
        tweakProviders.append(localTweakProvider_2)

        let tweakManager = TweakManager(tweakProviders: tweakProviders)
        tweakManager.useCache = true
        
        tweakManager.decryptionClosure = { tweak in
            String((tweak.value.stringValue).reversed()).eraseToAnyTweakValue()
        }
        
        return tweakManager
    }
}
