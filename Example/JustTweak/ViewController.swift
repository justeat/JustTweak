//
//  ViewController.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import UIKit
import JustTweak

enum Features : String {
    case UICustomization = "ui_customization"
}

enum Variables : String {
    case RedViewAlpha = "red_view_alpha_component"
    case DisplayRedView = "display_red_view"
    case DisplayGreenView = "display_green_view"
    case DisplayYellowView = "display_yellow_view"
    case TapToChangeViewColor = "tap_to_change_color_enabled"
    case ChangeConfigurationButton = "change_tweaks_button_label_text"
    case GreetOnAppDidBecomeActive = "greet_on_app_did_become_active"
}

class ViewController: UIViewController {

    @IBOutlet var redView: UIView!
    @IBOutlet var greenView: UIView!
    @IBOutlet var yellowView: UIView!
    @IBOutlet var changeConfigurationButton: UIButton!

    var configurationsCoordinator: TweaksConfigurationsCoordinator?
    private var tapGestureRecognizer: UITapGestureRecognizer!

    private var canShowRedView: Bool {
        get {
            let variable = Variables.DisplayRedView.rawValue
            return valueForExperiment(feature: Features.UICustomization.rawValue, variable: variable).boolValue
        }
    }
    private var canShowGreenView: Bool {
        get {
            let variable = Variables.DisplayGreenView.rawValue
            return valueForExperiment(feature: Features.UICustomization.rawValue, variable: variable).boolValue
        }
    }
    private var canShowYellowView: Bool {
        get {
            let variable = Variables.DisplayYellowView.rawValue
            return valueForExperiment(feature: Features.UICustomization.rawValue, variable: variable).boolValue
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
        configurationsCoordinator?.registerForConfigurationsUpdates(self) { [weak self] in
            self?.updateView()
        }
    }
    
    internal func updateView() {
        setUpGesturesIfNeeded()
        redView.isHidden = !canShowRedView
        greenView.isHidden = !canShowGreenView
        yellowView.isHidden = !canShowYellowView
        changeConfigurationButton.setTitle(valueForExperiment(feature: Features.UICustomization.rawValue, variable: Variables.ChangeConfigurationButton.rawValue).stringValue, for: .normal)
        redView.alpha = CGFloat(valueForExperiment(feature: Features.UICustomization.rawValue, variable: Variables.RedViewAlpha.rawValue).floatValue)
    }
    
    internal func setUpGesturesIfNeeded() {
        if tapGestureRecognizer == nil {
            tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeViewColor))
            view.addGestureRecognizer(tapGestureRecognizer)
        }
        tapGestureRecognizer.isEnabled = valueForExperiment(feature: Features.UICustomization.rawValue, variable: Variables.TapToChangeViewColor.rawValue).boolValue
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
        guard let coordinator = configurationsCoordinator else { return }
        let viewController = TweaksConfigurationViewController(style: .grouped, configurationsCoordinator: coordinator)
        viewController.title = "Edit Configuration"
        present(UINavigationController(rootViewController:viewController), animated: true, completion: nil)
    }

    private func valueForExperiment(feature: String, variable: String) -> TweakValue {
        return configurationsCoordinator?.valueForTweakWith(feature: feature, variable: variable) ?? 0
    }

}
