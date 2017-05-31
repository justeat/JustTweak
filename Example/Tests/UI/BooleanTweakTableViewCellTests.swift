
import XCTest
@testable import JustTweak

class BooleanTweakTableViewCellTests: XCTestCase {
    
    func testInformsDelegateOfValueChanges() {
        let mockDelegate = MockTweakCellDelegate()
        let cell = BooleanTweakTableViewCell()
        cell.delegate = mockDelegate
        cell.switchControl.sendActions(for: .valueChanged)
        XCTAssertTrue(mockDelegate.didCallDelegate)
    }
    
}
