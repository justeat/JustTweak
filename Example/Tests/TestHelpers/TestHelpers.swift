//
//  TestHelpers.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import Foundation
@testable import JustTweak

class MockTweakCellDelegate: TweakViewControllerCellDelegate {
    
    private(set) var didCallDelegate: Bool = false
    
    func tweakConfigurationCellDidChangeValue(_ cell: TweakViewControllerCell) {
        didCallDelegate = true
    }
    
}

class MockPresentingViewController: UIViewController {
    
    private(set) var didCallDismissal: Bool = false
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        didCallDismissal = true
    }
}
