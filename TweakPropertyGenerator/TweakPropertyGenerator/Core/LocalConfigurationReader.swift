//
//  LocalConfigurationReader.swift
//  Copyright © 2021 Just Eat Takeaway. All rights reserved.
//

import Foundation

typealias TweaksFormat = [String: [String: [String: Any]]]

extension String: Error {}

class LocalConfigurationReader {
    
    func loadTweaks(configurationFilePath: String) -> TweaksFormat {
        let url = URL(fileURLWithPath: configurationFilePath)
        do {
            let data = try Data(contentsOf: url)
            guard let content = try JSONSerialization.jsonObject(with: data) as? TweaksFormat else {
                throw "Invalid format"
            }
            return content
        } catch {
            print("FAILURE: Tweaks file '\(configurationFilePath)' is not valid JSON. Error: \(error)")
        }
        return [:]
    }
}
