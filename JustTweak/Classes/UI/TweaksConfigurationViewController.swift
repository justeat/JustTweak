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
    
    fileprivate struct Section {
        let title: String
        let tweaks: [Tweak]
    }
    
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
    
    private var sections = [Section]()
    private var filteredSections = [Section]()
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
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    public convenience init(style: UITableView.Style, configurationsCoordinator: TweaksConfigurationsCoordinator) {
        self.init(style: style)
        self.configurationsCoordinator = configurationsCoordinator
    }
    
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
        setupBarButtonItems()
        setupSearchController()
        registerCellClasses()
        rebuildSections()
    }
}

extension TweaksConfigurationViewController {

    public override func numberOfSections(in tableView: UITableView) -> Int {
        return isFiltering() ? filteredSections.count : sections.count
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
        let thisSection: Section = isFiltering() ? filteredSections[section] : sections[section]
        return thisSection.title
    }
    
    private func tweaksIn(section: Int) -> [Tweak] {
        let thisSection: Section = isFiltering() ? filteredSections[section] : sections[section]
        return thisSection.tweaks
    }
    
    fileprivate func tweakAt(indexPath: IndexPath) -> Tweak? {
        let tweaks = tweaksIn(section: (indexPath as NSIndexPath).section)
        return tweaks[(indexPath as NSIndexPath).row]
    }
}

extension TweaksConfigurationViewController {
    
    private func setupBarButtonItems() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                            target: self,
                                                            action: #selector(dismissViewController))
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("just_tweak_search_bar_placeholder_text",
                                                                   bundle: TweaksConfigurationViewController.justTweakResourcesBundle(),
                                                                   comment: "")
        searchController.searchBar.sizeToFit()
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
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
        var allSections = [Section]()
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
                    let section = Section(title: group, tweaks: items)
                    allSections.append(section)
                }
            }
        }
        sections = allSections.sorted { (lhs, rhs) -> Bool in
            return lhs.title < rhs.title
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

extension TweaksConfigurationViewController: UISearchResultsUpdating {
    
    public func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

extension TweaksConfigurationViewController {
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String) {
        filteredSections = [Section]()
        for section in sections {
            var filteredTweaks = [Tweak]()
            for tweak in section.tweaks {
                if let title = tweak.title, title.lowercased().contains(searchText.lowercased()) {
                    filteredTweaks.append(tweak)
                }
            }
            if filteredTweaks.count > 0 {
                let filteredSection = Section(title: section.title, tweaks: filteredTweaks)
                filteredSections.append(filteredSection)
            }
        }
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
}
