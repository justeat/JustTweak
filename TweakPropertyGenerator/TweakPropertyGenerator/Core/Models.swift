//
//  Models.swift
//  Copyright © 2021 Just Eat Takeaway. All rights reserved.
//

import Foundation

struct Configuration {
    let tweaks: [Tweak]
}

struct Tweak {
    let feature: String
    let variable: String
    let title: String
    let description: String
    let group: String
    let valueType: String
}
