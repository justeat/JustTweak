//
//  JustTweak+Presentation.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import Foundation

extension JustTweak {
    
    var displayableTweaks: [Tweak] {
        guard let localConfiguration = self.localConfiguration else {
            return []
        }
        var tweaks = [Tweak]()
        for (feature, variables) in localConfiguration.features {
            for variable in variables {
                if let tweak = tweakWith(feature: feature, variable: variable) {
                    let jsonTweak = localConfiguration.tweakWith(feature: feature, variable: variable)
                    let aggregatedTweak = Tweak(feature: feature,
                                                variable: variable,
                                                value: tweak.value,
                                                title: jsonTweak?.title,
                                                description: jsonTweak?.desc,
                                                group: jsonTweak?.group)
                    tweaks.append(aggregatedTweak)
                }
            }
        }
        return tweaks.sorted(by: { $0.displayTitle < $1.displayTitle })
    }
    
    private var localConfiguration: LocalConfiguration? {
        return configurations.first { $0 is LocalConfiguration } as? LocalConfiguration
    }
}
