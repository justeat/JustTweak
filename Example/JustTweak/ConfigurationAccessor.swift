//
//  ConfigurationAccessor.swift
//  JustTweak_Example
//
//  Created by Alberto De Bortoli on 02/11/2019.
//  Copyright © 2019 Just Eat. All rights reserved.
//

import Foundation
import JustTweak

class ConfigurationAccessor {
    
    lazy var configurationsCoordinator: TweaksConfigurationsCoordinator = {
        let jsonFileURL = Bundle.main.url(forResource: "ExampleConfiguration", withExtension: "json")!
        let jsonConfiguration = JSONTweaksConfiguration(jsonURL: jsonFileURL)!
        
        // let firebaseConfiguration = FirebaseTweaksConfiguration()
        
        // let optimizelyConfiguration = OptimizelyTweaksConfiguration()
        // optimizelyConfiguration.userId = UUID().uuidString
        
        let userDefaults = UserDefaults.standard
        let userDefaultsConfiguration = UserDefaultsTweaksConfiguration(userDefaults: userDefaults)
        
        let configurations: [TweaksConfiguration] = [jsonConfiguration, /*firebaseConfiguration, optimizelyConfiguration,*/ userDefaultsConfiguration]
        return TweaksConfigurationsCoordinator(configurations: configurations)
    }()
    
    var shouldShowAlert: Bool {
        return configurationsCoordinator.tweakWith(feature: Features.General,
                                                   variable: Variables.GreetOnAppDidBecomeActive)?.boolValue ?? false
    }
    
    var canShowRedView: Bool {
        return configurationsCoordinator.tweakWith(feature: Features.UICustomization,
                                                   variable: Variables.DisplayRedView)?.boolValue ?? false
    }
    
    var canShowGreenView: Bool {
        return configurationsCoordinator.tweakWith(feature: Features.UICustomization,
                                                   variable: Variables.DisplayGreenView)?.boolValue ?? false
    }
    
    var labelText: String {
        return configurationsCoordinator.tweakWith(feature: Features.UICustomization,
                                                   variable: Variables.LabelText)?.stringValue ?? ""
    }
    
    var canShowYellowView: Bool {
        return configurationsCoordinator.tweakWith(feature: Features.UICustomization,
                                                   variable: Variables.DisplayYellowView)?.boolValue ?? false
    }
    
    var redViewAlpha: Float {
        return configurationsCoordinator.tweakWith(feature: Features.UICustomization,
                                                   variable: Variables.RedViewAlpha)?.floatValue ?? 0.0
    }
    
    var isTapGestureToChangeColorEnabled: Bool {
        return configurationsCoordinator.tweakWith(feature: Features.General,
                                                   variable: Variables.TapToChangeViewColor)?.boolValue ?? false
    }
}
