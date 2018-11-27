![JustTweak Banner](./img/just_tweak_banner.png)

# JustTweak

[![Build Status](https://app.bitrise.io/app/375d99516a39bb82/status.svg?token=G7k3kFr7gFKb5y0gzuwH9Q&branch=master)](https://app.bitrise.io/app/375d99516a39bb82)
[![Version](https://img.shields.io/cocoapods/v/JustTweak.svg?style=flat)](http://cocoapods.org/pods/JustTweak)
[![License](https://img.shields.io/cocoapods/l/JustTweak.svg?style=flat)](http://cocoapods.org/pods/JustTweak)
[![Platform](https://img.shields.io/cocoapods/p/JustTweak.svg?style=flat)](http://cocoapods.org/pods/JustTweak)

JustTweak is a framework for feature flagging and A/B testing for iOS apps.
It provides a simple facade interface interacting with multiple providers that are queried respecting a given priority.
Tweaks represent flags used to drive decisions in the client code. 

With JustTweak you can achieve the following:

- use a JSON local configuration providing default values for experimentation 
- use a number of remote configuration providers such as Firebase and Optmizely to run A/B tests and feature flagging   
- enable, disable, and customize features locally at runtime
- provide a dedicated UI for customization (this comes particularly handy for feature that are under development to showcase it to stakeholders)


## Installation

JustTweak is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod "JustTweak"
```

## Implementation

### Integration

- define a JSON configuration file including your features (you can use the included `ExampleConfiguration.json` as a template)
- define your features and A/B tests in your services such as Firebase and Optmizely (optional)
- configure the JustTweak stack as following

```swift
// create a TweaksConfigurationsCoordinator
var configurationsCoordinator: TweaksConfigurationsCoordinator!

private func setupJustTweak() {

    // local JSON configuration (default tweaks)
    let jsonFileURL = Bundle.main.url(forResource: "ExampleConfiguration", withExtension: "json")!
    let jsonConfiguration = JSONTweaksConfiguration(jsonURL: jsonFileURL)!

    // remote configurations (optional)
    let firebaseConfiguration = FirebaseTweaksConfiguration()
    let optimizelyConfiguration = OptimizelyTweaksConfiguration()
    optimizelyConfiguration.userId = <#user_id#>
    
    // local mutable configuration (to override tweaks from other configurations)
    let userDefaultsConfiguration = UserDefaultsTweaksConfiguration(userDefaults: UserDefaults.standard)
    
    // priority is defined by the order in the configurations array (from low to high)
    let configurations: [TweaksConfiguration] = [jsonConfiguration,
                                                 firebaseConfiguration,
                                                 optimizelyConfiguration,
                                                 userDefaultsConfiguration]
    configurationsCoordinator = TweaksConfigurationsCoordinator(configurations: configurations)
}
```

The order of the objects in the `configurations` array defines the priority of the configurations. The `MutableTweaksConfiguration` with the highest priority, such as `UserDefaultsTweaksConfiguration` in the example above, will be used to load the `TweaksConfigurationViewController` UI. The `JSONTweaksConfiguration` should have the lowest priority as it provides the default values from a local configuration.


### Usage

The three main features of JustTweak can be accessed from the `TweaksConfigurationsCoordinator` instance to drive code path decisions.

1. Checking if a feature is enabled

```swift
// check for a feature to be enabled
let enabled = configurationsCoordinator.isFeatureEnabled("some_feature")
if enabled {
    // enable the feature
} else {
    // default behaviour
}
```

2. Get the value of a flag for a given feature. JustTweak will return the value from the configuration with the highest priority and automatically fallback to the others if no set value is found.

```swift
// check for a tweak value
let tweak = configurationsCoordinator.valueForTweakWith(feature: "some_feature", variable: "some_flag")
if let tweak = tweak {
    // tweak was found in some configuration, use tweak.value
} else {
    // tweak was not found in any configuration
}
```

3. Run an A/B test

```swift
// check for a tweak value
let variation = configurationsCoordinator.activeVariation(for: "some_experiment")
if let variation = variation {
   // act according to the kind of variation (e.g. "control", "variation_1")
} else {
   // default behaviour
}
```


### Caching

The `TweaksConfigurationsCoordinator` provides the ability to enable caching of the values to improve performance. Caching is disabled by default but can be enabled via the `useCache` property. When enabled, there are two ways to reset the cache:

- call the `resetCache` method on the  `TweaksConfigurationsCoordinator`
- post a `TweaksConfigurationDidChangeNotification` notification

### Update a configuration at runtime

JustTweak comes with a ViewController that allows the user to edit the `MutableTweaksConfiguration` with the highest priority.

```swift
func presentTweaksConfigurationViewController() {
    guard let coordinator = configurationsCoordinator else { return }
    let viewController = TweaksConfigurationViewController(style: .grouped, configurationsCoordinator: coordinator)
    viewController.title = "Edit Configuration"
    presentViewController(UINavigationController(rootViewController:viewController), animated: true, completion: nil)
}
```

When a value is modified in any `MutableTweaksConfiguration`, a notification is fired to give the clients the opportunity to react and reflect changes in the UI.

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    NotificationCenter.defaultCenter().addObserver(self,
                                                   selector: #selector(updateUI),
                                                   name: TweaksConfigurationDidChangeNotification,
                                                   object: nil)
}

@objc func updateUI() {
    // update the UI accordingly
}
```


### Customization

JustTweak comes with two configurations out-of-the-box:

- `UserDefaultsTweaksConfiguration` which is mutable and uses `UserDefaults` as a key/value store 
- `JSONTweaksConfiguration` which is read-only and uses a JSON configuration file that is meant to be the default configuration

In addition, JustTweak defines `TweaksConfiguration` and `MutableTweaksConfiguration` protocols you can implement to create your own configurations to fit your needs. In the example project you can find a few example configurations which you can use as a starting point.


## License

JustTweak is available under the Apache 2.0 license. See the LICENSE file for more info.


- Just Eat iOS team
