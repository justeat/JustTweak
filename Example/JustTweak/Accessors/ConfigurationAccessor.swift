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
        // let optimizelyTweakProvider = OptimizelyTweaksConfiguration()
        // optimizelyTweakProvider.userId = UUID().uuidString
        // configurations.append(optimizelyTweakProvider)
        
        // Firebase
        // let firebaseTweakProvider = FirebaseTweaksConfiguration()
        // configurations.append(firebaseTweakProvider)
        
        // LocalConfiguration
        #if CONFIGURATION_DEBUG
        let jsonFileURL_1 = Bundle.main.url(forResource: "LocalTweakProvider_TopPriority_example", withExtension: "json")!
        let localConfiguration_1 = LocalConfiguration(jsonURL: jsonFileURL_1)
        configurations.append(localConfiguration_1)
        #endif
        
        // LocalConfiguration
        let jsonFileURL_2 = Bundle.main.url(forResource: "LocalTweakProvider_example", withExtension: "json")!
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
                           feature: Features.uiCustomization,
                           variable: Variables.displayRedView,
                           tweakManager: tweakManager)
    var canShowRedView: Bool
    
    @FallbackTweakProperty(fallbackValue: false,
                           feature: Features.uiCustomization,
                           variable: Variables.displayGreenView,
                           tweakManager: tweakManager)
    var canShowGreenView: Bool
    
    @FallbackTweakProperty(fallbackValue: "",
                           feature: Features.uiCustomization,
                           variable: Variables.labelText,
                           tweakManager: tweakManager)
    var labelText: String
    
    @FallbackTweakProperty(fallbackValue: 42,
                           feature: Features.uiCustomization,
                           variable: Variables.meaningOfLife,
                           tweakManager: tweakManager)
    var meaningOfLife: Int
    
    @OptionalTweakProperty(fallbackValue: nil,
                           feature: Features.uiCustomization,
                           variable: Variables.answerToTheUniverse,
                           tweakManager: tweakManager)
    var optionalMeaningOfLife: Int?
    
    
    // MARK: - Via TweakManager
    
    var canShowYellowView: Bool {
        return tweakManager.tweakWith(feature: Features.uiCustomization,
                                      variable: Variables.displayYellowView)?.boolValue ?? false
    }
    
    var redViewAlpha: Float {
        return tweakManager.tweakWith(feature: Features.uiCustomization,
                                      variable: Variables.redViewAlpha)?.floatValue ?? 0.0
    }
    
    var isTapGestureToChangeColorEnabled: Bool {
        return tweakManager.tweakWith(feature: Features.general,
                                      variable: Variables.tapToChangeViewColor)?.boolValue ?? false
    }
}

