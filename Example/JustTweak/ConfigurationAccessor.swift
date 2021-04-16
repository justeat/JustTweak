//
//  ConfigurationAccessor.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import Foundation
import JustTweak

class ConfigurationAccessor {
    
    static let tweakManager: TweakManager = {
        var configurations: [Configuration] = []

        // UserDefaultsConfiguration
        let userDefaultsConfiguration_1 = UserDefaultsConfiguration(userDefaults: UserDefaults.standard)
        configurations.append(userDefaultsConfiguration_1)

        // Optimizely
        // let optimizelyConfiguration = OptimizelyTweaksConfiguration()
        // optimizelyConfiguration.userId = UUID().uuidString
        // configurations.append(optimizelyConfiguration)
        
        // Firebase
        // let firebaseConfiguration = FirebaseTweaksConfiguration()
        // configurations.append(firebaseConfiguration)
        
        // LocalConfiguration
        let jsonFileURL_1 = Bundle.main.url(forResource: "ExampleConfiguration", withExtension: "json")!
        let localConfiguration_1 = LocalConfiguration(jsonURL: jsonFileURL_1)
        configurations.append(localConfiguration_1)
        
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

