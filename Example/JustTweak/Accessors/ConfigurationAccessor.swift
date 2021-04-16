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
        #if DEBUG || CONFIGURATION_DEBUG
        let userDefaultsConfiguration_1 = UserDefaultsConfiguration(userDefaults: UserDefaults.standard)
        configurations.append(userDefaultsConfiguration_1)
        #endif
        
        // Optimizely
        // let optimizelyConfiguration = OptimizelyTweaksConfiguration()
        // optimizelyConfiguration.userId = UUID().uuidString
        // configurations.append(optimizelyConfiguration)
        
        // Firebase
        // let firebaseConfiguration = FirebaseTweaksConfiguration()
        // configurations.append(firebaseConfiguration)
        
        // LocalConfiguration
        #if CONFIGURATION_DEBUG
        let jsonFileURL_1 = Bundle.main.url(forResource: "ExampleConfiguration_TopPriority", withExtension: "json")!
        let localConfiguration_1 = LocalConfiguration(jsonURL: jsonFileURL_1)
        configurations.append(localConfiguration_1)
        #endif
        
        // LocalConfiguration
        let jsonFileURL_2 = Bundle.main.url(forResource: "ExampleConfiguration", withExtension: "json")!
        let localConfiguration_2 = LocalConfiguration(jsonURL: jsonFileURL_2)
        configurations.append(localConfiguration_2)
        
        return TweakManager(configurations: configurations)
    }()
    
    private var tweakManager: TweakManager {
        return Self.tweakManager
    }
    
    // MARK: - Via Property Wrappers
    
    @FallbackTweakProperty(fallbackValue: false,
                           feature: Features.general,
                           variable: Variables.greetOnAppDidBecomeActive,
                           tweakManager: tweakManager)
    var shouldShowAlert: Bool
    
    @FallbackTweakProperty(fallbackValue: false,
                           feature: Features.UICustomization,
                           variable: Variables.displayRedView,
                           tweakManager: tweakManager)
    var canShowRedView: Bool
    
    @FallbackTweakProperty(fallbackValue: false,
                           feature: Features.UICustomization,
                           variable: Variables.displayGreenView,
                           tweakManager: tweakManager)
    var canShowGreenView: Bool
    
    @FallbackTweakProperty(fallbackValue: "",
                           feature: Features.UICustomization,
                           variable: Variables.labelText,
                           tweakManager: tweakManager)
    var labelText: String
    
    @FallbackTweakProperty(fallbackValue: 42,
                           feature: Features.UICustomization,
                           variable: Variables.meaningOfLife,
                           tweakManager: tweakManager)
    var meaningOfLife: Int
    
    @OptionalTweakProperty(fallbackValue: nil,
                           feature: Features.UICustomization,
                           variable: Variables.answerToTheUniverse,
                           tweakManager: tweakManager)
    var optionalMeaningOfLife: Int?
    
    
    // MARK: - Via TweakManager
    
    var canShowYellowView: Bool {
        return tweakManager.tweakWith(feature: Features.UICustomization,
                                      variable: Variables.displayYellowView)?.boolValue ?? false
    }
    
    var redViewAlpha: Float {
        return tweakManager.tweakWith(feature: Features.UICustomization,
                                      variable: Variables.redViewAlpha)?.floatValue ?? 0.0
    }
    
    var isTapGestureToChangeColorEnabled: Bool {
        return tweakManager.tweakWith(feature: Features.general,
                                      variable: Variables.tapToChangeViewColor)?.boolValue ?? false
    }
}

