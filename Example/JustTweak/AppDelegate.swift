//
//  AppDelegate.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import JustTweak
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var configurationsCoordinator: TweaksConfigurationsCoordinator!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        setUpConfigurations()
        if let rootViewController = window?.rootViewController as? ViewController {
            rootViewController.configurationsCoordinator = configurationsCoordinator
        }
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        let shouldShowAlert = configurationsCoordinator.valueForTweakWith(feature: Features.UICustomization.rawValue, variable: Variables.GreetOnAppDidBecomeActive.rawValue)
        if let shouldShowAlert = shouldShowAlert, shouldShowAlert == true {
            let alertController = UIAlertController(title: "Hello",
                                                    message: "Welcome to this Demo app!",
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Continue", style: .default, handler: nil))
            window!.rootViewController!.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func setUpConfigurations() {
        let jsonFileURL = Bundle.main.url(forResource: "ExampleConfiguration", withExtension: "json")!
        let jsonConfiguration = JSONTweaksConfiguration(defaultValuesFromJSONAtURL: jsonFileURL)!
        
        let userDefaults = UserDefaults.standard
        let localConfiguration = UserDefaultsTweaksConfiguration(userDefaults: userDefaults)
        
        let firebaseConfiguration = FirebaseTweaksConfiguration()

        let optimizelyConfiguration = OptimizelyTweaksConfiguration()
        optimizelyConfiguration.userId = UUID().uuidString

        let configurations: [TweaksConfiguration] = [jsonConfiguration, localConfiguration, firebaseConfiguration, optimizelyConfiguration]
        configurationsCoordinator = TweaksConfigurationsCoordinator(configurations: configurations)
    }
    
}
