//
//  Models.swift
//  Copyright © 2021 Just Eat Takeaway. All rights reserved.
//

import Foundation

struct Tweak: Equatable {
    let feature: String
    let variable: String
    let title: String
    let description: String
    let group: String
    let valueType: String
    let propertyName: String?
}

struct Configuration: Decodable {
    let configurations: [TweakConfiguration]
    let shouldCacheTweaks: Bool
    let stackName: String
}

struct TweakConfiguration: Decodable {
    let type: String
    let parameter: String
    let propertyName: String?
    let macros: [String]?
}
