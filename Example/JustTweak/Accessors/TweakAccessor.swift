//
//  TweakAccessor.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import Foundation
import JustTweak

class TweakAccessor {
    
    static let tweakManager: TweakManager = {
        var tweakProviders: [TweakProvider] = []
        
        // UserDefaultsTweakProvider
        #if DEBUG || CONFIGURATION_DEBUG
        let userDefaultsTweakProvider_1 = UserDefaultsTweakProvider(userDefaults: UserDefaults.standard)
        tweakProviders.append(userDefaultsTweakProvider_1)
        #endif
        
        // OptimizelyTweakProvider
        // let optimizelyTweakProvider = OptimizelyTweakProvider()
        // optimizelyTweakProvider.userId = UUID().uuidString
        // tweakProviders.append(optimizelyTweakProvider)
        
        // FirebaseTweakProvider
        // let firebaseTweakProvider = FirebaseTweakProvider()
        // tweakProviders.append(firebaseTweakProvider)
        
        // LocalTweakProvider
        #if CONFIGURATION_DEBUG
        let jsonFileURL_1 = Bundle.main.url(forResource: "LocalTweaks_TopPriority_example", withExtension: "json")!
        let localTweakProvider_1 = LocalTweakProvider(jsonURL: jsonFileURL_1)
        tweakProviders.append(localTweakProvider_1)
        #endif
        
        // LocalTweakProvider
        let jsonFileURL_2 = Bundle.main.url(forResource: "LocalTweaks_example", withExtension: "json")!
        let localTweakProvider_2 = LocalTweakProvider(jsonURL: jsonFileURL_2)
        tweakProviders.append(localTweakProvider_2)
        
        return TweakManager(tweakProviders: tweakProviders)
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
        return (try? tweakManager.tweakWith(feature: Features.uiCustomization,
                                            variable: Variables.displayYellowView))?.boolValue ?? false
    }

    var redViewAlpha: Float {
        return (try? tweakManager.tweakWith(feature: Features.uiCustomization,
                                            variable: Variables.redViewAlpha))?.floatValue ?? 0.0
    }

    var isTapGestureToChangeColorEnabled: Bool {
        return (try? tweakManager.tweakWith(feature: Features.general,
                                            variable: Variables.tapToChangeViewColor))?.boolValue ?? false
    }
}

