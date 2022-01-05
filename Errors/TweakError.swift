//
//  TweakError.swift
//  JustTweak
//
//  Created by Sania Zafar on 06/01/2022.
//

import Foundation

public enum TweakError: String, Error {
    case notFound = "Feature or variable is not found"
    case notSupported = "Variable type is not supported"
    case decryptionClosureNotProvided = "Value is encrypted but there's no decryption closure provided"
}
