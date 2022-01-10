//
//  TweakError.swift
//  Copyright (c) 2022 Just Eat Holding Ltd. All rights reserved.
//

import Foundation

public enum TweakError: String, Error {
    case notFound = "Feature or variable is not found"
    case notSupported = "Variable type is not supported"
    case decryptionClosureNotProvided = "Value is encrypted but there's no decryption closure provided"
}
