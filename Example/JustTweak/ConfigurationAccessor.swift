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
    
    static let configurationsCoordinator: JustTweak = {
        let userDefaultsConfiguration = UserDefaultsConfiguration(userDefaults: UserDefaults.standard)
        
        // let optimizelyConfiguration = OptimizelyTweaksConfiguration()
        // optimizelyConfiguration.userId = UUID().uuidString
        
        // let firebaseConfiguration = FirebaseTweaksConfiguration()
        
        let jsonFileURL = Bundle.main.url(forResource: "ExampleConfiguration", withExtension: "json")!
        let localConfiguration = LocalConfiguration(jsonURL: jsonFileURL)!
        
        let configurations: [Configuration] = [userDefaultsConfiguration, /*optimizelyConfiguration, firebaseConfiguration*/ localConfiguration]
        return JustTweak(configurations: configurations)
    }()
    
    private var configurationsCoordinator: JustTweak {
        return Self.configurationsCoordinator
    }
    
    // MARK: - Via Property Wrappers
    
    @FeatureFlag(fallbackValue: false,
                 feature: Features.General,
                 variable: Variables.GreetOnAppDidBecomeActive,
                 coordinator: configurationsCoordinator)
    var shouldShowAlert: Bool
    
    @FeatureFlag(fallbackValue: false,
                 feature: Features.UICustomization,
                 variable: Variables.DisplayRedView,
                 coordinator: configurationsCoordinator)
    var canShowRedView: Bool
    
    @FeatureFlag(fallbackValue: false,
                 feature: Features.UICustomization,
                 variable: Variables.DisplayGreenView,
                 coordinator: configurationsCoordinator)
    var canShowGreenView: Bool
    
    @FeatureFlag(fallbackValue: "",
                 feature: Features.UICustomization,
                 variable: Variables.LabelText,
                 coordinator: configurationsCoordinator)
    var labelText: String
    
    @FeatureFlagWrappingOptional(fallbackValue: nil,
                                 feature: Features.UICustomization,
                                 variable: Variables.MeaningOfLife,
                                 coordinator: configurationsCoordinator)
    var meaningOfLife: Int?
    
    // MARK: - Via ConfigurationsCoordinator
    
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
