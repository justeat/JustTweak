//
//  Models.swift
//  Copyright © 2021 Just Eat Takeaway. All rights reserved.
//

import Foundation

struct Tweak: Equatable {
    let feature: String
    let variable: String
    let title: String
    let description: String?
    let group: String
    let valueType: String
    let propertyName: String?
}

struct Configuration: Decodable {
    let tweakProviders: [TweakProvider]
    let shouldCacheTweaks: Bool
    let accessorName: String
}

struct TweakProvider: Decodable {
    let type: String
    let parameter: String?
    let macros: [String]?
}
