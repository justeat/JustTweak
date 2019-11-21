//
//  TextTweakTableViewCellTests.swift
//  Copyright (c) 2019 Just Eat Holding Ltd. All rights reserved.
//

import XCTest
@testable import JustTweak

class TextTweakTableViewCellTests: XCTestCase {
    
    func testInformsDelegateOfValueChanges() {
        let mockDelegate = MockTweakCellDelegate()
        let cell = TextTweakTableViewCell()
        cell.delegate = mockDelegate
        cell.textField.sendActions(for: .editingDidEnd)
        XCTAssertTrue(mockDelegate.didCallDelegate)
    }
    
    func testUpdatesTweakValueWhenTextChanges() {
        let cell = TextTweakTableViewCell()
        cell.value = "Old Value"
        cell.textField.text = "Some new value"
        cell.textField.sendActions(for: .editingChanged)
        XCTAssertTrue(cell.value == "Some new value")
    }
    
    func testUpdatesTweakValueWhenTextChangesToNil() {
        let cell = TextTweakTableViewCell()
        cell.value = "Old Value"
        cell.textField.text = nil
        cell.textField.sendActions(for: .editingChanged)
        XCTAssertTrue(cell.value == "")
    }
    
    func testTextFieldNeverGrowsMoreThanHalfTheSizeOfTheCell() {
        let cell = TextTweakTableViewCell(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
        cell.value = "Some extremely long string that wouldn't fit in 320 points"
        XCTAssertTrue(cell.textField.bounds.width <= 160)
    }
    
    func testTextFieldResignsFirstResponderOnReturn() {
        let cell = TextTweakTableViewCell(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
        // HACK to get the text field to become first responder
        UIApplication.shared.delegate?.window??.addSubview(cell)
        cell.textField.becomeFirstResponder()
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0))
        // HACKEND
        XCTAssertTrue(cell.textField.isFirstResponder)
        let _ = cell.textField.delegate?.textFieldShouldReturn?(cell.textField)
        XCTAssertFalse(cell.textField.isFirstResponder)
    }
    
}
