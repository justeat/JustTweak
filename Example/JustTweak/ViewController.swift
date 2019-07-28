//
//  ViewController.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import UIKit
import JustTweak

class ViewController: UIViewController {

    @IBOutlet var redView: UIView!
    @IBOutlet var greenView: UIView!
    @IBOutlet var yellowView: UIView!
    @IBOutlet var mainLabel: UILabel!
    
    var configurationsCoordinator: TweaksConfigurationsCoordinator!
    private var tapGestureRecognizer: UITapGestureRecognizer!
    
    private var canShowRedView: Bool {
        get {
            return valueForExperiment(feature: Features.UICustomization.rawValue, variable: Variables.DisplayRedView.rawValue).boolValue
        }
    }
    private var canShowGreenView: Bool {
        get {
            return valueForExperiment(feature: Features.UICustomization.rawValue, variable: Variables.DisplayGreenView.rawValue).boolValue
        }
    }
    private var canShowYellowView: Bool {
        get {
            return valueForExperiment(feature: Features.UICustomization.rawValue, variable: Variables.DisplayYellowView.rawValue).boolValue
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
        configurationsCoordinator?.registerForConfigurationsUpdates(self, closure: { [weak self] (tweakIdentifier) in
            print("\(tweakIdentifier ?? "Unknown") tweak changed")
            self?.updateView()
        })
    }
    
    internal func updateView() {
        setUpGesturesIfNeeded()
        redView.isHidden = !canShowRedView
        greenView.isHidden = !canShowGreenView
        yellowView.isHidden = !canShowYellowView
        mainLabel.text = valueForExperiment(feature: Features.UICustomization.rawValue, variable: Variables.LabelText.rawValue).stringValue
        redView.alpha = CGFloat(valueForExperiment(feature: Features.UICustomization.rawValue, variable: Variables.RedViewAlpha.rawValue).floatValue)
    }
    
    internal func setUpGesturesIfNeeded() {
        if tapGestureRecognizer == nil {
            tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeViewColor))
            view.addGestureRecognizer(tapGestureRecognizer)
        }
        tapGestureRecognizer.isEnabled = valueForExperiment(feature: Features.General.rawValue, variable: Variables.TapToChangeViewColor.rawValue).boolValue
    }
    
    @objc internal func changeViewColor() {
        func randomColorValue() -> CGFloat {
            return CGFloat(arc4random() % 255) / 255.0
        }
        view.backgroundColor = UIColor(red: randomColorValue(),
                                       green: randomColorValue(),
                                       blue: randomColorValue(),
                                       alpha: 1.0)
    }
    
    @IBAction func presentConfigurationViewController() {
        let tweaksViewController = TweaksConfigurationViewController(style: .grouped, configurationsCoordinator: configurationsCoordinator)
        let tweaksNavigationController = UINavigationController(rootViewController:tweaksViewController)
        tweaksNavigationController.navigationBar.prefersLargeTitles = true
        present(tweaksNavigationController, animated: true, completion: nil)
    }
    
    @IBAction func pushConfigurationViewController() {
        let tweaksViewController = TweaksConfigurationViewController(style: .grouped, configurationsCoordinator: configurationsCoordinator)
        navigationController?.pushViewController(tweaksViewController, animated: true)
    }

    private func valueForExperiment(feature: String, variable: String) -> TweakValue {
        let value = configurationsCoordinator?.valueForTweakWith(feature: feature, variable: variable)
        return value ?? 0
    }
}
