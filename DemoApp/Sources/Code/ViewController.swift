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
    
    var tweakAccessor: GeneratedTweakAccessor!
    var tweakManager: TweakManager!
    
    private var tapGestureRecognizer: UITapGestureRecognizer!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(setAndShowMeaningOfLife))
        tapGestureRecognizer.numberOfTapsRequired = 2
        view.addGestureRecognizer(tapGestureRecognizer)
        tweakManager.registerForConfigurationsUpdates(self) { [weak self] tweak in
            print("Tweak changed: \(tweak)")
            self?.updateView()
        }
        addEncryptedMeaningOfLifeTapGesture()
    }
    
    private func addEncryptedMeaningOfLifeTapGesture() {
        let tapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(showEncryptedMeaningOfLife))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    internal func updateView() {
        setUpGestures()
        redView.isHidden = !tweakAccessor.canShowRedView
        greenView.isHidden = !tweakAccessor.canShowGreenView
        yellowView.isHidden = !tweakAccessor.canShowYellowView
        mainLabel.text = tweakAccessor.labelText
        redView.alpha = CGFloat(tweakAccessor.redViewAlpha)
    }
    
    internal func setUpGestures() {
        if tapGestureRecognizer == nil {
            tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeViewColor))
            view.addGestureRecognizer(tapGestureRecognizer)
        }
        tapGestureRecognizer.isEnabled = tweakAccessor.isTapGestureToChangeColorEnabled
    }
    
    @objc internal func setAndShowMeaningOfLife() {
        tweakAccessor.meaningOfLife = Bool.random() ? 42 : 108
        let alertController = UIAlertController(title: "The Meaning of Life",
                                                message: String(describing: tweakAccessor.meaningOfLife),
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func showEncryptedMeaningOfLife() {
        let alertController = UIAlertController(title: "Encrypted Meaning of Life",
                                                message: String(describing: tweakAccessor.definitiveAnswerEncrypted),
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
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
    
    private var tweakViewController: TweakViewController {
        return TweakViewController(style: .grouped, tweakManager: tweakManager)
    }
    
    @IBAction func presentTweakViewController() {
        let tweakNavigationController = UINavigationController(rootViewController: tweakViewController)
        tweakNavigationController.navigationBar.prefersLargeTitles = true
        present(tweakNavigationController, animated: true, completion: nil)
    }
    
    @IBAction func pushTweakViewController() {
        navigationController?.pushViewController(tweakViewController, animated: true)
    }
}
