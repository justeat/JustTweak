//
//  TweaksErrorView
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import UIKit

internal class TweaksErrorView: UIView {

    var text: String? {
        didSet {
            label.text = text
        }
    }
    private lazy var label: UILabel = {
        let label = UILabel()
        self.addSubview(label)
        let centerX = NSLayoutConstraint(item:label,
                                         attribute:.centerX,
                                         relatedBy:.equal,
                                         toItem:label.superview,
                                         attribute:.centerX,
                                         multiplier:1.0,
                                         constant:0.0)
        let centerY = NSLayoutConstraint(item:label,
                                         attribute:.centerY,
                                         relatedBy:.equal,
                                         toItem:label.superview,
                                         attribute:.centerY,
                                         multiplier:1.0,
                                         constant:0.0)
        let maxWidth = NSLayoutConstraint(item:label,
                                          attribute:.width,
                                          relatedBy:.lessThanOrEqual,
                                          toItem:label.superview,
                                          attribute:.width,
                                          multiplier:1.0,
                                          constant:0.0)
        let constraints = [centerX, centerY, maxWidth]
        NSLayoutConstraint.activate(constraints)
        label.preferredMaxLayoutWidth = self.frame.width - 20.0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.darkGray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
}
