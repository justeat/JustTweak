//
//  BooleanTweakTableViewCell
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import UIKit

internal class BooleanTweakTableViewCell: UITableViewCell, TweaksConfigurationViewControllerCell {
    
    var title: String? {
        get {
            return textLabel?.text
        }
        set {
            textLabel?.text = newValue
        }
    }
    var value: TweakValue {
        get {
            return switchControl.isOn
        }
        set {
            switchControl.isOn = newValue.boolValue
        }
    }
    weak var delegate: TweaksConfigurationViewControllerCellDelegate?
    
    lazy var switchControl: UISwitch! = {
        let switchControl = UISwitch()
        switchControl.addTarget(self, action: #selector(didChangeTweakValue), for: .valueChanged)
        self.accessoryView = switchControl
        self.selectionStyle = .none
        return switchControl
    }()
    
    @objc func didChangeTweakValue() {
        delegate?.tweaksConfigurationCellDidChangeValue(self)
    }
    
}
