//
//  AppDelegate.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import JustTweak
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let configurationAccessor = ConfigurationAccessor()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        let vc = storyboard.instantiateViewController(identifier: "ViewController", creator: { coder in
            return ViewController(coder: coder, configurationAccessor: self.configurationAccessor, configurationsCoordinator: ConfigurationAccessor.configurationsCoordinator)
        })
        let navigationController = UINavigationController()
        window?.rootViewController = navigationController
        navigationController.pushViewController(vc, animated: true)
        window?.makeKeyAndVisible()
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if configurationAccessor.shouldShowAlert {
            let alertController = UIAlertController(title: "Hello",
                                                    message: "Welcome to this Demo app!",
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Continue", style: .default, handler: nil))
            window?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
}
