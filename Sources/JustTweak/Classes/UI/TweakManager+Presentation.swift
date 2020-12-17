//
//  TweakManager+Presentation.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import Foundation

extension TweakManager {
    
    var displayableTweaks: [Tweak] {
        var tweaks = [String : Tweak]()
        for localConfiguration in self.localConfigurations.reversed() {
            for (feature, variables) in localConfiguration.features {
                for variable in variables {
                    if let tweak = tweakWith(feature: feature, variable: variable),
                        let jsonTweak = localConfiguration.tweakWith(feature: feature, variable: variable) {
                        let aggregatedTweak = Tweak(feature: feature,
                                                    variable: variable,
                                                    value: tweak.value,
                                                    title: jsonTweak.title,
                                                    description: jsonTweak.desc,
                                                    group: jsonTweak.group)
                        let key = "\(feature)-\(variable)"
                        tweaks[key] = aggregatedTweak
                    }
                }
            }
        }
        return tweaks.values.sorted(by: { $0.displayTitle < $1.displayTitle })
    }
    
    private var localConfigurations: [LocalConfiguration] {
        return configurations.filter { $0 is LocalConfiguration } as! [LocalConfiguration]
    }
}
