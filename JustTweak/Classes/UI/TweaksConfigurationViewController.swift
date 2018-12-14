//
//  TweaksConfigurationViewController
//  Copyright (c) 2016 Just Eat Holding Ltd. All rights reserved.
//

import UIKit

internal protocol TweaksConfigurationViewControllerCell: class {
    var title: String? { get set }
    var desc: String? { get set }
    var value: TweakValue { get set }
    var delegate: TweaksConfigurationViewControllerCellDelegate? { get set }
}

internal protocol TweaksConfigurationViewControllerCellDelegate: class {
    func tweaksConfigurationCellDidChangeValue(_ cell: TweaksConfigurationViewControllerCell)
}

public class TweaksConfigurationViewController: UITableViewController {
    
    fileprivate class Tweak {
        var feature: String
        var variable: String
        var title: String?
        var desc: String?
        var value: TweakValue
        
        init(feature: String, variable: String, value: TweakValue, title: String?, description: String?) {
            self.feature = feature
            self.variable = variable
            self.value = value
            self.title = title
            self.desc = description
        }
    }
    
    private enum CellIdentifiers: String {
        case ToogleCell, TextCell, NumberCell
    }
    
    private enum SectionGroupKeys: String {
        case Title, Items
    }
    
    private var sections: [[String : Any]]?
    public var configurationsCoordinator: TweaksConfigurationsCoordinator? {
        didSet {
            rebuildSections()
            updateBackgroundView()
        }
    }
    
    private class func justTweakResourcesBundle() -> Bundle {
        let podBundle = Bundle(for: TweaksConfigurationViewController.self)
        let resourcesBundleURL = podBundle.url(forResource: "JustTweak", withExtension: "bundle")!
        let justTweakResourcesBundle = Bundle(url: resourcesBundleURL)!
        return justTweakResourcesBundle
    }
    
    private lazy var defaultGroupName: String! = {
        return NSLocalizedString("just_tweak_unnamed_tweaks_group_title",
                                 bundle: TweaksConfigurationViewController.justTweakResourcesBundle(),
                                 comment: "")
    }()
    
    // MARK: Convenience Initializers
    
    public convenience init(style: UITableView.Style, configurationsCoordinator: TweaksConfigurationsCoordinator) {
        self.init(style: style)
        self.configurationsCoordinator = configurationsCoordinator
    }
    
    // MARK: View Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundView = TweaksErrorView()
        let bundle = TweaksConfigurationViewController.justTweakResourcesBundle()
        backgroundView.text = NSLocalizedString("just_tweak_configurations_vc_no_configurations_message",
                                                bundle: bundle,
                                                comment: "")
        tableView.backgroundView = backgroundView
        tableView.keyboardDismissMode = .onDrag
        updateBackgroundView()
        setUpBarButtonItems()
        registerCellClasses()
        rebuildSections()
    }
    
    // MARK: UITableViewDataSource
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return sections?.count ?? 0
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweaksIn(section: section).count
    }
    
    public override func tableView(_ table: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tweak = tweakAt(indexPath: indexPath)!
        let cellIdentifier = cellIdentifierForTweak(tweak)
        let cell = table.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if let cell = cell as? TweaksConfigurationViewControllerCell {
            cell.title = tweak.title ?? "\(tweak.feature):\(tweak.variable)"
            cell.desc = tweak.desc
            cell.value = tweak.value
            cell.delegate = self
        }
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleForHeaderForSection(section)
    }
    
    // MARK: Convenience
    
    public func indexPathForTweak(with feature: String, variable: String) -> IndexPath? {
        for section in 0 ..< numberOfSections(in: tableView) {
            for (row, tweak) in tweaksIn(section: section).enumerated() {
                if tweak.feature == feature, tweak.variable == variable {
                    return IndexPath(row: row, section: section)
                }
            }
        }
        return nil
    }
    
    // MARK: Helpers
    
    private func cellIdentifierForTweak(_ tweak: Tweak) -> String {
        if let _ = tweak.value as? Bool {
            return CellIdentifiers.ToogleCell.rawValue
        }
        else if let _ = tweak.value as? String {
            return CellIdentifiers.TextCell.rawValue
        }
        return CellIdentifiers.NumberCell.rawValue
    }
    
    private func titleForHeaderForSection(_ section: Int) -> String? {
        let thisSection = sections?[section]
        return thisSection?[SectionGroupKeys.Title.rawValue] as? String
    }
    
    private func tweaksIn(section: Int) -> [Tweak] {
        let thisSection = sections?[section]
        return thisSection?[SectionGroupKeys.Items.rawValue] as! [Tweak]
    }
    
    fileprivate func tweakAt(indexPath: IndexPath) -> Tweak? {
        let tweaks = tweaksIn(section: (indexPath as NSIndexPath).section)
        return tweaks[(indexPath as NSIndexPath).row]
    }
    
    private func setUpBarButtonItems() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                            target: self,
                                                            action: #selector(dismissViewController))
    }
    
    private func registerCellClasses() {
        tableView.register(BooleanTweakTableViewCell.self,
                           forCellReuseIdentifier: CellIdentifiers.ToogleCell.rawValue)
        tableView.register(NumericTweakTableViewCell.self,
                           forCellReuseIdentifier: CellIdentifiers.NumberCell.rawValue)
        tableView.register(TextTweakTableViewCell.self,
                           forCellReuseIdentifier: CellIdentifiers.TextCell.rawValue)
    }
    
    private func rebuildSections() {
        var allSections = [[String : Any]]()
        if let configurationsCoordinator = configurationsCoordinator {
            let allTweaks = configurationsCoordinator.displayableTweaks().sorted(by: { (lhs, rhs) -> Bool in
                return lhs.displayTitle < rhs.displayTitle
            })
            var allGroups: Set<String> = []
            for tweak in allTweaks {
                allGroups.insert(tweak.group ?? defaultGroupName)
            }
            
            for group in allGroups {
                var items = [Tweak]()
                for tweak in allTweaks {
                    if tweak.group == group || (tweak.group == nil && group == defaultGroupName) {
                        let dto = Tweak(feature: tweak.feature,
                                        variable: tweak.variable,
                                        value: tweak.value,
                                        title: tweak.title,
                                        description: tweak.desc)
                        items.append(dto)
                    }
                }
                if items.count > 0 {
                    let section: [String : Any] = [SectionGroupKeys.Items.rawValue: items,
                                                   SectionGroupKeys.Title.rawValue: group]
                    allSections.append(section)
                }
            }
        }
        sections = allSections.sorted { (lhs, rhs) -> Bool in
            return (lhs[SectionGroupKeys.Title.rawValue] as! String) < (rhs[SectionGroupKeys.Title.rawValue] as! String)
        }
        
        tableView.reloadData()
    }
    
    private func updateBackgroundView() {
        tableView.backgroundView?.isHidden = configurationsCoordinator?.topCustomizableConfiguration() != nil
    }
    
    @objc internal func dismissViewController() {
        view.endEditing(true)
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension TweaksConfigurationViewController: TweaksConfigurationViewControllerCellDelegate {
    
    internal func tweaksConfigurationCellDidChangeValue(_ cell: TweaksConfigurationViewControllerCell) {
        if let indexPath = tableView.indexPath(for: cell as! UITableViewCell) {
            if let tweak = tweakAt(indexPath: indexPath) {
                let configuration = configurationsCoordinator?.topCustomizableConfiguration()
                let feature = tweak.feature
                let variable = tweak.variable
                configuration?.set(value: cell.value, feature: feature, variable: variable)
                tweak.value = cell.value
            }
        }
    }
}
