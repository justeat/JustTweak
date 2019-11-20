//
//  TestHelpers.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import Foundation
@testable import JustTweak

class MockTweakCellDelegate: TweaksViewControllerCellDelegate {
    
    private(set) var didCallDelegate: Bool = false
    
    func tweaksConfigurationCellDidChangeValue(_ cell: TweaksViewControllerCell) {
        didCallDelegate = true
    }
    
}

class MockPresentingViewController: UIViewController {
    
    private(set) var didCallDismissal: Bool = false
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        didCallDismissal = true
    }
}
