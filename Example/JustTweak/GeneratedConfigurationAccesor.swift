//
//  GeneratedConfigurationAccesor.swift
//  Generated via JustTweak
//

import Foundation
import JustTweak

class GeneratedConfigurationAccesor {

    struct Features {
        static let general = "general"
        static let uiCustomization = "ui_customization"
    }

    struct Variables {
        static let displayGreenView = "display_green_view"
        static let displayRedView = "display_red_view"
        static let displayYellowView = "display_yellow_view"
        static let greetOnAppDidBecomeActive = "greet_on_app_did_become_active"
        static let labelText = "label_text"
        static let redViewAlphaComponent = "red_view_alpha_component"
        static let tapToChangeColorEnabled = "tap_to_change_color_enabled"
    }

    static let tweakManager: TweakManager = {
        let userDefaultsConfiguration = UserDefaultsConfiguration(userDefaults: UserDefaults.standard)
        
        let jsonFileURL = Bundle.main.url(forResource: "ExampleConfiguration", withExtension: "json")!
        let localConfiguration = LocalConfiguration(jsonURL: jsonFileURL)
        
        let configurations: [Configuration] = [userDefaultsConfiguration, localConfiguration]
        return TweakManager(configurations: configurations)
    }()
        
    private var tweakManager: TweakManager {
        return Self.tweakManager
    }

    @TweakProperty(feature: Features.general,
                   variable: Variables.greetOnAppDidBecomeActive,
                   tweakManager: tweakManager)
    var greetOnAppDidBecomeActive: Bool

    @TweakProperty(feature: Features.general,
                   variable: Variables.tapToChangeColorEnabled,
                   tweakManager: tweakManager)
    var tapToChangeColorEnabled: Bool

    @TweakProperty(feature: Features.uiCustomization,
                   variable: Variables.displayGreenView,
                   tweakManager: tweakManager)
    var displayGreenView: Bool

    @TweakProperty(feature: Features.uiCustomization,
                   variable: Variables.displayRedView,
                   tweakManager: tweakManager)
    var displayRedView: Bool

    @TweakProperty(feature: Features.uiCustomization,
                   variable: Variables.displayYellowView,
                   tweakManager: tweakManager)
    var displayYellowView: Bool

    @TweakProperty(feature: Features.uiCustomization,
                   variable: Variables.labelText,
                   tweakManager: tweakManager)
    var labelText: String

    @TweakProperty(feature: Features.uiCustomization,
                   variable: Variables.redViewAlphaComponent,
                   tweakManager: tweakManager)
    var redViewAlphaComponent: Double
}