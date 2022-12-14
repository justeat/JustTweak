//
//  BooleanTweakTableViewCellTests.swift
//  Copyright (c) 2019 Just Eat Holding Ltd. All rights reserved.
//

import UIKit
import XCTest
@testable import JustTweak

class BooleanTweakTableViewCellTests: XCTestCase {
    
    func testInformsDelegateOfValueChanges() {
        let mockDelegate = MockTweakCellDelegate()
        let cell = BooleanTweakTableViewCell()
        cell.delegate = mockDelegate
        cell.didChangeTweakValue()
        XCTAssertTrue(mockDelegate.didCallDelegate)
    }
    
}
