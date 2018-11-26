//
//  TextTweakTableViewCell
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import UIKit

class TextTweakTableViewCell: UITableViewCell, TweaksConfigurationViewControllerCell, UITextFieldDelegate {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
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
    
    var value: TweakValue = "" {
        didSet {
            textField.text = value.description
            textField.sizeToFit()
            if textField.bounds.width > bounds.width / 2.0 {
                textField.bounds.size = CGSize(width: bounds.width / 2.0,
                                               height: textField.bounds.size.height)
            }
        }
    }
    weak var delegate: TweaksConfigurationViewControllerCellDelegate?
    
    var keyboardType: UIKeyboardType {
        get {
            return .default
        }
    }
    
    lazy var textField: UITextField! = {
        let textField = UITextField()
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        textField.addTarget(self, action: #selector(textEditingDidEnd), for: .editingDidEnd)
        textField.textColor = UIColor.darkGray
        textField.keyboardType = self.keyboardType
        textField.returnKeyType = .done
        textField.textAlignment = .right
        textField.borderStyle = .none
        textField.delegate = self
        self.accessoryView = textField
        self.selectionStyle = .none
        return textField
    }()
    
    @objc func textDidChange() {
        value = textField.text!
    }
    
    @objc func textEditingDidEnd() {
        delegate?.tweaksConfigurationCellDidChangeValue(self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }

}
