//
//  ConfigurationAccessor.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import Foundation
import JustTweak

class ConfigurationAccessor {
    
    static let tweakManager: TweakManager = {
        let userDefaultsConfiguration = UserDefaultsConfiguration(userDefaults: UserDefaults.standard)
        
        // let optimizelyConfiguration = OptimizelyTweaksConfiguration()
        // optimizelyConfiguration.userId = UUID().uuidString
        
        // let firebaseConfiguration = FirebaseTweaksConfiguration()
        
        let jsonFileURL = Bundle.main.url(forResource: "ExampleConfiguration", withExtension: "json")!
        let localConfiguration = LocalConfiguration(jsonURL: jsonFileURL)
        
        let configurations: [Configuration] = [userDefaultsConfiguration, localConfiguration]
        // let configurations: [Configuration] = [userDefaultsConfiguration, optimizelyConfiguration, firebaseConfiguration, localConfiguration]
        return TweakManager(configurations: configurations)
    }()
    
    private var tweakManager: TweakManager {
        return Self.tweakManager
    }
    
    // MARK: - Via Property Wrappers
    
    @FallbackTweakProperty(fallbackValue: false,
                           feature: Features.General,
                           variable: Variables.GreetOnAppDidBecomeActive,
                           tweakManager: tweakManager)
    var shouldShowAlert: Bool
    
    @FallbackTweakProperty(fallbackValue: false,
                           feature: Features.UICustomization,
                           variable: Variables.DisplayRedView,
                           tweakManager: tweakManager)
    var canShowRedView: Bool
    
    @FallbackTweakProperty(fallbackValue: false,
                           feature: Features.UICustomization,
                           variable: Variables.DisplayGreenView,
                           tweakManager: tweakManager)
    var canShowGreenView: Bool
    
    @FallbackTweakProperty(fallbackValue: "",
                           feature: Features.UICustomization,
                           variable: Variables.LabelText,
                           tweakManager: tweakManager)
    var labelText: String
    
    @OptionalTweakProperty(fallbackValue: nil,
                           feature: Features.UICustomization,
                           variable: Variables.MeaningOfLife,
                           tweakManager: tweakManager)
    var meaningOfLife: Int?
    
    // MARK: - Via TweakManager
    
    var canShowYellowView: Bool {
        return tweakManager.tweakWith(feature: Features.UICustomization,
                                      variable: Variables.DisplayYellowView)?.boolValue ?? false
    }
    
    var redViewAlpha: Float {
        return tweakManager.tweakWith(feature: Features.UICustomization,
                                      variable: Variables.RedViewAlpha)?.floatValue ?? 0.0
    }
    
    var isTapGestureToChangeColorEnabled: Bool {
        return tweakManager.tweakWith(feature: Features.General,
                                      variable: Variables.TapToChangeViewColor)?.boolValue ?? false
    }
}

