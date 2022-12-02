//
//  BooleanTweakTableViewCell
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import UIKit

internal class BooleanTweakTableViewCell: UITableViewCell, TweakViewControllerCell {

    private var _feature: String? = nil
    private var _variable: String? = nil

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var title: String? {
        get {
            return textLabel?.text
        }
        set {
            textLabel?.text = newValue
        }
    }
    
    var desc: String? {
        get {
            return detailTextLabel?.text
        }
        set {
            detailTextLabel?.text = newValue
        }
    }

    var feature: String? {
        get {
            return self._feature
        }

        set {
            self._feature = newValue
        }
    }

    var variable: String? {
        get {
            return self._variable
        }

        set {
            self._variable = newValue
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
    weak var delegate: TweakViewControllerCellDelegate?
    
    lazy var switchControl: UISwitch! = {
        let switchControl = UISwitch()
        switchControl.addTarget(self, action: #selector(didChangeTweakValue), for: .valueChanged)
        self.accessoryView = switchControl
        self.selectionStyle = .none
        return switchControl
    }()
    
    @objc func didChangeTweakValue() {
        delegate?.tweakConfigurationCellDidChangeValue(self)
    }
    
}
