//
//  EphemeralTweakProviderTests.swift
//  Copyright © 2021 Just Eat Takeaway. All rights reserved.
//

import XCTest
@testable import JustTweak

final class EphemeralTweakProviderTests: XCTestCase {
    private var ephemeralTweakProvider: NSDictionary!

    override func setUpWithError() throws {
        try super.setUpWithError()
        ephemeralTweakProvider = NSDictionary()
    }

    override func tearDownWithError() throws {
        ephemeralTweakProvider = nil
        try super.tearDownWithError()
    }
    
    func testDefaultDecryptionClosure() {
        XCTAssertNil(ephemeralTweakProvider.decryptionClosure)
        
        ephemeralTweakProvider.decryptionClosure = { tweak in
            tweak.value
        }
        
        XCTAssertNil(ephemeralTweakProvider.decryptionClosure)
    }
}
