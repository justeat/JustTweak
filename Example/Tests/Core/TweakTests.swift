
import XCTest
import JustTweak

class TweakTests: XCTestCase {
    
    func testTweakHashIsEqualToHashValue() {
        let tweak = Tweak(identifier: "some_tweak", title: nil, group: nil, value: false, canBeDisplayed: false)
        XCTAssertEqual(tweak.hashValue, tweak.hash)
    }
    
    func testTweakIsEqualToOtherTweakWithSameAttributes() {
        let tweakA = Tweak(identifier: "some_tweak", title: nil, group: nil, value: false, canBeDisplayed: false)
        let tweakB = Tweak(identifier: "some_tweak", title: nil, group: nil, value: false, canBeDisplayed: false)
        XCTAssertEqual(tweakA, tweakB)
    }
    
    func testTweakIsNotEqualToOtherTweakWithSameIdentifierButDifferentAttributes() {
        let tweakA = Tweak(identifier: "some_tweak", title: nil, group: nil, value: false, canBeDisplayed: false)
        let tweakB = Tweak(identifier: "some_tweak", title: nil, group: nil, value: true, canBeDisplayed: false)
        XCTAssertNotEqual(tweakA, tweakB)
    }
    
    func testTweakIsNotEqualToSomeOtherObjectClaimingToBeATweak() {
        let tweakA = Tweak(identifier: "some_tweak", title: nil, group: nil, value: false, canBeDisplayed: false)
        let tweakB = NSObject()
        XCTAssertNotEqual(tweakA, tweakB)
    }
    
    func testStringTweakIsEqualToOtherTweakWithSameAttributes() {
        let tweakA = Tweak(identifier: "some_tweak", title: nil, group: nil, value: "Test", canBeDisplayed: false)
        let tweakB = Tweak(identifier: "some_tweak", title: nil, group: nil, value: "Test", canBeDisplayed: false)
        XCTAssertEqual(tweakA, tweakB)
    }
    
    func testIntTweakIsEqualToOtherTweakWithSameAttributes() {
        let tweakA = Tweak(identifier: "some_tweak", title: nil, group: nil, value: 1, canBeDisplayed: false)
        let tweakB = Tweak(identifier: "some_tweak", title: nil, group: nil, value: 1, canBeDisplayed: false)
        XCTAssertEqual(tweakA, tweakB)
    }
    
    func testFloatTweakIsEqualToOtherTweakWithSameAttributes() {
        let value: Float = 1.0
        let tweakA = Tweak(identifier: "some_tweak", title: nil, group: nil, value: value, canBeDisplayed: false)
        let tweakB = Tweak(identifier: "some_tweak", title: nil, group: nil, value: value, canBeDisplayed: false)
        XCTAssertEqual(tweakA, tweakB)
    }
    
    func testDoubleTweakIsEqualToOtherTweakWithSameAttributes() {
        let value: Double = 1.0
        let tweakA = Tweak(identifier: "some_tweak", title: nil, group: nil, value: value, canBeDisplayed: false)
        let tweakB = Tweak(identifier: "some_tweak", title: nil, group: nil, value: value, canBeDisplayed: false)
        XCTAssertEqual(tweakA, tweakB)
    }
    
    func testMethodsToBrigeValuesToObjectiveC_Bool() {
        let value: Double = 1.0
        let tweakA = Tweak(identifier: "some_tweak", title: nil, group: nil, value: value, canBeDisplayed: false)
        XCTAssertFalse(tweakA.boolValue)
        let tweakB = Tweak(identifier: "some_tweak", title: nil, group: nil, value: true, canBeDisplayed: false)
        XCTAssertTrue(tweakB.boolValue)
    }
    
    func testMethodsToBrigeValuesToObjectiveC_Int() {
        let value: Int = 1
        let tweak = Tweak(identifier: "some_tweak", title: nil, group: nil, value: value, canBeDisplayed: false)
        XCTAssertEqual(tweak.intValue, value)
    }
    
    func testMethodsToBrigeValuesToObjectiveC_Float() {
        let value: Float = 1.5
        let tweak = Tweak(identifier: "some_tweak", title: nil, group: nil, value: value, canBeDisplayed: false)
        XCTAssertEqual(tweak.floatValue, value)
    }
    
    func testMethodsToBrigeValuesToObjectiveC_Double() {
        let value: Double = 3.66
        let tweak = Tweak(identifier: "some_tweak", title: nil, group: nil, value: value, canBeDisplayed: false)
        XCTAssertEqual(tweak.doubleValue, value)
    }
    
    func testMethodsToBrigeValuesToObjectiveC_String() {
        let value: String = "3.66"
        let tweak = Tweak(identifier: "some_tweak", title: nil, group: nil, value: value, canBeDisplayed: false)
        XCTAssertEqual(tweak.stringValue, value)
    }
    
    func testMethodsToBridgeValuesToObjectiveC_ReturnCorrectValues_FromNumber() {
        let tweak = Tweak(identifier: "some_tweak",
                          title: nil,
                          group: nil,
                          value: 3.5,
                          canBeDisplayed: false)
        XCTAssertEqual(tweak.doubleValue, 3.5)
        XCTAssertEqual(tweak.floatValue, 3.5)
        XCTAssertEqual(tweak.intValue, 3)
        XCTAssertEqual(tweak.boolValue, false)
        XCTAssertNil(tweak.stringValue)
    }

    func testMethodsToBridgeValuesToObjectiveC_ReturnCorrectValues_FromBool() {
        let tweak = Tweak(identifier: "some_tweak",
                          title: nil,
                          group: nil,
                          value: true,
                          canBeDisplayed: false)
        XCTAssertEqual(tweak.doubleValue, 0.0)
        XCTAssertEqual(tweak.floatValue, 0.0)
        XCTAssertEqual(tweak.intValue, 0)
        XCTAssertEqual(tweak.boolValue, true)
        XCTAssertNil(tweak.stringValue)
    }
    
    func testMethodsToBridgeValuesToObjectiveC_ReturnCorrectValues_FromString() {
        let tweak = Tweak(identifier: "some_tweak",
                          title: nil,
                          group: nil,
                          value: "Hello",
                          canBeDisplayed: false)
        XCTAssertEqual(tweak.doubleValue, 0.0)
        XCTAssertEqual(tweak.floatValue, 0.0)
        XCTAssertEqual(tweak.intValue, 0)
        XCTAssertEqual(tweak.boolValue, false)
        XCTAssertEqual(tweak.stringValue, "Hello")
    }
    
}
