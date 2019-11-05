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
    
    let configurationAccessor: ConfigurationAccessor
    let configurationsCoordinator: TweaksConfigurationsCoordinator
    
    private var tapGestureRecognizer: UITapGestureRecognizer!
    
    init?(coder: NSCoder, configurationAccessor: ConfigurationAccessor, configurationsCoordinator: TweaksConfigurationsCoordinator) {
        self.configurationAccessor = configurationAccessor
        self.configurationsCoordinator = configurationsCoordinator
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("You must create this view controller with a ConfigurationAccessor and a TweaksConfigurationsCoordinator.")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(setAndShowMeaningOfLife))
        tapGestureRecognizer.numberOfTapsRequired = 2
        view.addGestureRecognizer(tapGestureRecognizer)
        configurationsCoordinator.registerForConfigurationsUpdates(self) { [weak self] tweak in
            print("Tweak changed: \(tweak)")
            self?.updateView()
        }
    }
    
    internal func updateView() {
        setUpGestures()
        redView.isHidden = !configurationAccessor.canShowRedView
        greenView.isHidden = !configurationAccessor.canShowGreenView
        yellowView.isHidden = !configurationAccessor.canShowYellowView
        mainLabel.text = configurationAccessor.labelText
        redView.alpha = CGFloat(configurationAccessor.redViewAlpha)
    }
    
    internal func setUpGestures() {
        if tapGestureRecognizer == nil {
            tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeViewColor))
            view.addGestureRecognizer(tapGestureRecognizer)
        }
        tapGestureRecognizer.isEnabled = configurationAccessor.isTapGestureToChangeColorEnabled
    }
    
    @objc internal func setAndShowMeaningOfLife() {
        configurationAccessor.meaningOfLife = Bool.random() ? 42 : nil
        let alertController = UIAlertController(title: "The Meaning of Life",
                                                message: String(describing: configurationAccessor.meaningOfLife),
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
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
    
    private var tweaksConfigurationViewController: TweaksConfigurationViewController {
        return TweaksConfigurationViewController(style: .grouped, configurationsCoordinator: configurationsCoordinator)
    }
    
    @IBAction func presentConfigurationViewController() {
        let tweaksNavigationController = UINavigationController(rootViewController: tweaksConfigurationViewController)
        tweaksNavigationController.navigationBar.prefersLargeTitles = true
        present(tweaksNavigationController, animated: true, completion: nil)
    }
    
    @IBAction func pushConfigurationViewController() {
        navigationController?.pushViewController(tweaksConfigurationViewController, animated: true)
    }
}
