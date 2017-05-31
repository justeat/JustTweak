
import Foundation
@testable import JustTweak

class MockTweakCellDelegate: TweaksConfigurationViewControllerCellDelegate {
    
    private(set) var didCallDelegate: Bool = false
    
    func tweaksConfigurationCellDidChangeValue(_ cell: TweaksConfigurationViewControllerCell) {
        didCallDelegate = true
    }
    
}

class MockPresentingViewController: UIViewController {
    
    private(set) var didCallDismissal: Bool = false
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        didCallDismissal = true
    }
}
