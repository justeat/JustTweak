//
//  TweakViewControllerTests.swift
//  Copyright (c) 2019 Just Eat Holding Ltd. All rights reserved.
//

import XCTest
@testable import JustTweak

class TweakViewControllerTests: XCTestCase {
    
    private var rootWindow: UIWindow!
    private var viewController: TweakViewController!
    private var tweakManager: TweakManager!
    
    override func setUp() {
        super.setUp()
        let bundle = Bundle(for: TweakViewControllerTests.self)
        let jsonURL = bundle.url(forResource: "LocalTweaks_test", withExtension: "json")
        let localTweakProvider = LocalTweakProvider(jsonURL: jsonURL!)
        let userDefaults = UserDefaults(suiteName: "com.JustTweaks.Tests\(NSDate.timeIntervalSinceReferenceDate)")!
        let userDefaultsTweakProvider = UserDefaultsTweakProvider(userDefaults: userDefaults)
        let tweakProviders: [TweakProvider] = [userDefaultsTweakProvider, localTweakProvider]
        tweakManager = TweakManager(tweakProviders: tweakProviders)
        viewController = TweakViewController(style: .plain, tweakManager: tweakManager)
        
        rootWindow = UIWindow(frame: UIScreen.main.bounds)
        rootWindow.makeKeyAndVisible()
        rootWindow.isHidden = false
        rootWindow.rootViewController = viewController
        _ = viewController.view
        viewController.viewWillAppear(false)
        viewController.viewDidAppear(false)
    }
    
    override func tearDown() {
        let mutableTweakProvider = tweakManager.mutableTweakProvider!
        mutableTweakProvider.deleteValue(feature: "feature_1", variable: "variable_1")
        viewController = nil
        
        let rootViewController = rootWindow!.rootViewController!
        rootViewController.viewWillDisappear(false)
        rootViewController.viewDidDisappear(false)
        rootWindow.rootViewController = nil
        rootWindow.isHidden = true
        self.rootWindow = nil
        self.viewController = nil
        
        super.tearDown()
    }
    
    // MARK: Generic Data Display
    
    func testHasExpectedNumberOfSections() {
        XCTAssertEqual(2, viewController.numberOfSections(in: viewController.tableView))
    }
    
    func testGroupedTweaksAreDisplayedInTheirOwnSections() {
        XCTAssertEqual(2, viewController.tableView(viewController.tableView, numberOfRowsInSection: 0))
        XCTAssertEqual("General", viewController.tableView(viewController.tableView, titleForHeaderInSection: 0))
        XCTAssertEqual(5, viewController.tableView(viewController.tableView, numberOfRowsInSection: 1))
        XCTAssertEqual("UI Customization", viewController.tableView(viewController.tableView, titleForHeaderInSection: 1))
    }
    
    // MARK: Convenience Methods
    
    func testReturnsCorrectIndexPathForTweak_WhenTweakFound() {
        let indexPath = viewController.indexPathForTweak(with: Features.uiCustomization, variable: Variables.displayGreenView)!
        let expectedIndexPath = IndexPath(row: 0, section: 1)
        XCTAssertEqual(indexPath, expectedIndexPath)
    }
    
    func testReturnsCorrectIndexPathForTweak_WhenTweakFound_2() {
        let indexPath = viewController.indexPathForTweak(with: Features.uiCustomization, variable: Variables.displayRedView)!
        let expectedIndexPath = IndexPath(row: 1, section: 1)
        XCTAssertEqual(indexPath, expectedIndexPath)
    }
    
    func testReturnsCorrectIndexPathForTweak_WhenTweakFound_3() {
        let indexPath = viewController.indexPathForTweak(with: Features.uiCustomization, variable: Variables.displayYellowView)!
        let expectedIndexPath = IndexPath(row: 2, section: 1)
        XCTAssertEqual(indexPath, expectedIndexPath)
    }
    
    // MARK: Tweak Cells Display
    
    func testReturnsCorrectIndexPathForTweak_WhenTweakNotFound() {
        let indexPath = viewController.indexPathForTweak(with: Features.general, variable: "some_nonexisting_tweak")
        XCTAssertNil(indexPath)
    }
    
    func testDisplaysTweakOn_IfEnabled() {
        let indexPath = viewController.indexPathForTweak(with: Features.uiCustomization, variable: Variables.displayYellowView)!
        let cell = viewController.tableView(viewController.tableView, cellForRowAt: indexPath) as! BooleanTweakTableViewCell
        XCTAssertFalse(cell.switchControl.isOn)
    }
    
    func testDisplaysTweakOff_IfDisabled() {
        let indexPath = viewController.indexPathForTweak(with: Features.uiCustomization, variable: Variables.displayRedView)!
        let cell = viewController.tableView(viewController.tableView, cellForRowAt: indexPath) as! BooleanTweakTableViewCell
        XCTAssertTrue(cell.switchControl.isOn)
    }
    
    func testDisplaysTweakTitle_ForTweakThatHaveIt() {
        let indexPath = viewController.indexPathForTweak(with: Features.uiCustomization, variable: Variables.displayRedView)!
        let cell = viewController.tableView(viewController.tableView, cellForRowAt: indexPath)
        XCTAssertEqual(cell.textLabel?.text, "Display Red View")
        XCTAssertEqual((cell as! TweakViewControllerCell).title, "Display Red View")
    }
    
    func testDisplaysNumericTweaksCorrectly() {
        let indexPath = viewController.indexPathForTweak(with: Features.uiCustomization, variable: Variables.redViewAlpha)!
        let cell = viewController.tableView(viewController.tableView, cellForRowAt: indexPath) as? NumericTweakTableViewCell
        XCTAssertEqual(cell?.title, "Red View Alpha Component")
        XCTAssertEqual(cell?.textField.text, "1.0")
    }
    
    func testDisplaysTextTweaksCorrectly() {
        let indexPath = viewController.indexPathForTweak(with: Features.uiCustomization, variable: Variables.labelText)!
        let cell = viewController.tableView(viewController.tableView, cellForRowAt: indexPath)  as? TextTweakTableViewCell
        XCTAssertEqual(cell?.title, "Label Text")
        XCTAssertEqual(cell?.textField.text, "Test value")
    }
    
    // MARK: Cells Actions
    
    func testUpdatesValueOfTweak_WhenUserTooglesSwitchOnBooleanCell() throws {
        viewController.beginAppearanceTransition(true, animated: false)
        viewController.endAppearanceTransition()
        
        let indexPath = viewController.indexPathForTweak(with: Features.uiCustomization, variable: Variables.displayYellowView)!
        let cell = viewController.tableView.cellForRow(at: indexPath) as! BooleanTweakTableViewCell
        cell.switchControl.isOn = true
        cell.switchControl.sendActions(for: .valueChanged)
        XCTAssertTrue(try XCTUnwrap(tweakManager.tweakWith(feature: Features.uiCustomization, variable: Variables.displayYellowView)).boolValue)
    }
    
    // MARK: Other Actions
    
    func testAsksToBeDismissedWhenDoneButtonIsTapped() {
        class FakeViewController: TweakViewController {
            fileprivate let mockPresentingViewController = MockPresentingViewController()
            override var presentingViewController: UIViewController? {
                get {
                    return mockPresentingViewController
                }
            }
        }
        let vc = FakeViewController(style: .grouped, tweakManager: tweakManager)
        vc.dismissViewController()
        XCTAssertTrue(vc.mockPresentingViewController.didCallDismissal)
    }
}
