//
//  ViewController.swift
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import UIKit
import JustTweak

class ViewController: UIViewController {

    private enum ExperimentIdentifiers : String {
        case RedViewAlpha = "red_view_alpha_component"
        case DisplayRedView = "display_red_view"
        case DisplayGreenView = "display_green_view"
        case DisplayYellowView = "display_yellow_view"
        case TapToChangeViewColor = "tap_to_change_color_enabled"
        case ChangeConfigurationButton = "change_tweaks_button_label_text"
    }

    @IBOutlet var redView: UIView!
    @IBOutlet var greenView: UIView!
    @IBOutlet var yellowView: UIView!
    @IBOutlet var changeConfigurationButton: UIButton!

    var configurationsCoordinator: TweaksConfigurationsCoordinator?
    private var tapGestureRecognizer: UITapGestureRecognizer!

    private var canShowRedView: Bool {
        get {
            let identifier = ExperimentIdentifiers.DisplayRedView.rawValue
            return valueForExperiment(withIdentifier: identifier).boolValue
        }
    }
    private var canShowGreenView: Bool {
        get {
            let identifier = ExperimentIdentifiers.DisplayGreenView.rawValue
            return valueForExperiment(withIdentifier: identifier).boolValue
        }
    }
    private var canShowYellowView: Bool {
        get {
            let identifier = ExperimentIdentifiers.DisplayYellowView.rawValue
            return valueForExperiment(withIdentifier: identifier).boolValue
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
        changeConfigurationButton.setTitle(valueForExperiment(withIdentifier: ExperimentIdentifiers.ChangeConfigurationButton.rawValue).stringValue, for: .normal)
        redView.alpha = CGFloat(valueForExperiment(withIdentifier: ExperimentIdentifiers.RedViewAlpha.rawValue).floatValue)
    }
    
    internal func setUpGesturesIfNeeded() {
        if tapGestureRecognizer == nil {
            tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeViewColor))
            view.addGestureRecognizer(tapGestureRecognizer)
        }
        tapGestureRecognizer.isEnabled = valueForExperiment(withIdentifier: ExperimentIdentifiers.TapToChangeViewColor.rawValue).boolValue
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

    private func valueForExperiment(withIdentifier identifier: String) -> TweakValue {
        return configurationsCoordinator?.valueForTweakWith(feature: identifier) ?? 0
    }

}
