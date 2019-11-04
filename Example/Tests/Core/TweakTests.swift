
import XCTest
import JustTweak

class TweakTests: XCTestCase {
    
    func testTweakIsEqualToOtherTweakWithSameAttributes() {
        let tweakA = Tweak(feature: "some_feature", variable: "some_variable", value: false, title: nil, group: nil)
        let tweakB = Tweak(feature: "some_feature", variable: "some_variable", value: false, title: nil, group: nil)
        XCTAssertEqual(tweakA, tweakB)
    }
    
    func testTweakIsNotEqualToOtherTweakWithSameIdentifierButDifferentAttributes() {
        let tweakA = Tweak(feature: "some_feature", variable: "some_variable", value: false, title: nil, group: nil)
        let tweakB = Tweak(feature: "some_feature", variable: "some_variable", value: true, title: nil, group: nil)
        XCTAssertNotEqual(tweakA, tweakB)
    }
    
    func testStringTweakIsEqualToOtherTweakWithSameAttributes() {
        let tweakA = Tweak(feature: "some_feature", variable: "some_variable", value: "Test", title: nil, group: nil)
        let tweakB = Tweak(feature: "some_feature", variable: "some_variable", value: "Test", title: nil, group: nil)
        XCTAssertEqual(tweakA, tweakB)
    }
    
    func testIntTweakIsEqualToOtherTweakWithSameAttributes() {
        let tweakA = Tweak(feature: "some_feature", variable: "some_variable", value: 1, title: nil, group: nil)
        let tweakB = Tweak(feature: "some_feature", variable: "some_variable", value: 1, title: nil, group: nil)
        XCTAssertEqual(tweakA, tweakB)
    }
    
    func testFloatTweakIsEqualToOtherTweakWithSameAttributes() {
        let value: Float = 1.0
        let tweakA = Tweak(feature: "some_feature", variable: "some_variable", value: value, title: nil, group: nil)
        let tweakB = Tweak(feature: "some_feature", variable: "some_variable", value: value, title: nil, group: nil)
        XCTAssertEqual(tweakA, tweakB)
    }
    
    func testDoubleTweakIsEqualToOtherTweakWithSameAttributes() {
        let value: Double = 1.0
        let tweakA = Tweak(feature: "some_feature", variable: "some_variable", value: value, title: nil, group: nil)
        let tweakB = Tweak(feature: "some_feature", variable: "some_variable", value: value, title: nil, group: nil)
        XCTAssertEqual(tweakA, tweakB)
    }
    
    func testMethodsToBrigeValuesToObjectiveC_Bool() {
        let value: Double = 1.0
        let tweakA = Tweak(feature: "some_feature", variable: "some_variable", value: value, title: nil, group: nil)
        XCTAssertFalse(tweakA.boolValue)
        let tweakB = Tweak(feature: "some_feature", variable: "some_variable", value: true, title: nil, group: nil)
        XCTAssertTrue(tweakB.boolValue)
    }
    
    func testMethodsToBrigeValuesToObjectiveC_Int() {
        let value: Int = 1
        let tweak = Tweak(feature: "some_feature", variable: "some_variable", value: value, title: nil, group: nil)
        XCTAssertEqual(tweak.intValue, value)
    }
    
    func testMethodsToBrigeValuesToObjectiveC_Float() {
        let value: Float = 1.5
        let tweak = Tweak(feature: "some_feature", variable: "some_variable", value: value, title: nil, group: nil)
        XCTAssertEqual(tweak.floatValue, value)
    }
    
    func testMethodsToBrigeValuesToObjectiveC_Double() {
        let value: Double = 3.66
        let tweak = Tweak(feature: "some_feature", variable: "some_variable", value: value, title: nil, group: nil)
        XCTAssertEqual(tweak.doubleValue, value)
    }
    
    func testMethodsToBrigeValuesToObjectiveC_String() {
        let value: String = "3.66"
        let tweak = Tweak(feature: "some_feature", variable: "some_variable", value: value, title: nil, group: nil)
        XCTAssertEqual(tweak.stringValue, value)
    }
    
    func testMethodsToBridgeValuesToObjectiveC_ReturnCorrectValues_FromNumber() {
        let tweak = Tweak(feature: "some_feature",
                          variable: "some_variable",
                          value: 3.5,
                          title: nil,
                          group: nil)
        XCTAssertEqual(tweak.doubleValue, 3.5)
        XCTAssertEqual(tweak.floatValue, 3.5)
        XCTAssertEqual(tweak.intValue, 3)
        XCTAssertEqual(tweak.boolValue, false)
        XCTAssertNil(tweak.stringValue)
    }

    func testMethodsToBridgeValuesToObjectiveC_ReturnCorrectValues_FromBool() {
        let tweak = Tweak(feature: "some_feature",
                          variable: "some_variable",
                          value: true,
                          title: nil,
                          group: nil)
        XCTAssertEqual(tweak.doubleValue, 0.0)
        XCTAssertEqual(tweak.floatValue, 0.0)
        XCTAssertEqual(tweak.intValue, 0)
        XCTAssertEqual(tweak.boolValue, true)
        XCTAssertNil(tweak.stringValue)
    }
    
    func testMethodsToBridgeValuesToObjectiveC_ReturnCorrectValues_FromString() {
        let tweak = Tweak(feature: "some_feature",
                          variable: "some_variable",
                          value: "Hello",
                          title: nil,
                          group: nil)
        XCTAssertEqual(tweak.doubleValue, 0.0)
        XCTAssertEqual(tweak.floatValue, 0.0)
        XCTAssertEqual(tweak.intValue, 0)
        XCTAssertEqual(tweak.boolValue, false)
        XCTAssertEqual(tweak.stringValue, "Hello")
    }
    
}
