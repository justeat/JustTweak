//
//  TweakManager+PresentationTests.swift
//  JustTweak_Tests
//
//  Created by Alberto De Bortoli on 02/02/2020.
//  Copyright © 2020 Just Eat. All rights reserved.
//

import XCTest
@testable import JustTweak

class TweakManager_PresentationTests: XCTestCase {
    
    var tweakManager: TweakManager!
    let localTweakProviderLowPriority: LocalTweakProvider = {
       // let bundle = Bundle(for: TweakManagerTests.self)
        let jsonConfigurationURL = Bundle.module.url(forResource: "LocalTweaks_test", withExtension: "json")!
        return LocalTweakProvider(jsonURL: jsonConfigurationURL)
    }()
    let localTweakProviderHighPriority: LocalTweakProvider = {
       // let bundle = Bundle(for: TweakManagerTests.self)
        let jsonConfigurationURL = Bundle.module.url(forResource: "LocalTweaks_test_override", withExtension: "json")!
        return LocalTweakProvider(jsonURL: jsonConfigurationURL)
    }()
    
    func test_GivenOneLocalTweakProvider_WhenFetchedDisplayableTweaks_ThenAllTweaksSortedByTitleAreReturned() {
        let tweakProviders: [TweakProvider] = [localTweakProviderLowPriority]
        tweakManager = TweakManager(tweakProviders: tweakProviders)
        let displayableTweaks = tweakManager.displayableTweaks
        let targetTweaks = [
            Tweak(feature: "ui_customization",
                  variable: "display_green_view",
                  value: true,
                  title: "Display Green View",
                  group: "UI Customization"),
            Tweak(feature: "ui_customization",
                  variable: "display_red_view",
                  value: true,
                  title: "Display Red View",
                  group: "UI Customization"),
            Tweak(feature: "ui_customization",
                  variable: "display_yellow_view",
                  value: false,
                  title: "Display Yellow View",
                  group: "UI Customization"),
            Tweak(feature: "general",
                  variable: "greet_on_app_did_become_active",
                  value: false,
                  title: "Greet on app launch",
                  group: "General"),
            Tweak(feature: "ui_customization",
                  variable: "label_text",
                  value: "Test value",
                  title: "Label Text",
                  group: "UI Customization"),
            Tweak(feature: "ui_customization",
                  variable: "red_view_alpha_component",
                  value: 1.0,
                  title: "Red View Alpha Component",
                  group: "UI Customization"),
            Tweak(feature: "general",
                  variable: "tap_to_change_color_enabled",
                  value: true,
                  title: "Tap to change views color",
                  group: "General")
        ]
        XCTAssertEqual(displayableTweaks, targetTweaks)
    }
    
    func test_GivenTwoLocalTweakProviders_WhenFetchedDisplayableTweaks_ThenTweaksFromBothConfigurationsSortedByTitleAreReturned() {
        let tweakProviders: [LocalTweakProvider] = [localTweakProviderHighPriority, localTweakProviderLowPriority]
        tweakManager = TweakManager(tweakProviders: tweakProviders)
        let displayableTweaks = tweakManager.displayableTweaks
        let targetTweaks = [
            Tweak(feature: "ui_customization",
                  variable: "display_blue_view",
                  value: true,
                  title: "Display Blue View",
                  group: "UI Customization"),
            Tweak(feature: "ui_customization",
                  variable: "display_green_view",
                  value: true,
                  title: "Display Green View",
                  group: "UI Customization"),
            Tweak(feature: "ui_customization",
                  variable: "display_red_view",
                  value: true,
                  title: "Display Red View",
                  group: "UI Customization"),
            Tweak(feature: "ui_customization",
                  variable: "display_yellow_view",
                  value: true,
                  title: "Display Yellow View",
                  group: "UI Customization"),
            Tweak(feature: "general",
                  variable: "greet_on_app_did_become_active",
                  value: false,
                  title: "Greet on app launch",
                  group: "General"),
            Tweak(feature: "ui_customization",
                  variable: "label_text",
                  value: "Overridden value",
                  title: "Label Text",
                  group: "UI Customization"),
            Tweak(feature: "ui_customization",
                  variable: "red_view_alpha_component",
                  value: 1.0,
                  title: "Red View Alpha Component",
                  group: "UI Customization"),
            Tweak(feature: "general",
                  variable: "tap_to_change_color_enabled",
                  value: false,
                  title: "Tap to change views color",
                  group: "General")
        ]
        XCTAssertEqual(displayableTweaks, targetTweaks)
    }
}
