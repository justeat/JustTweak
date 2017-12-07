![JustTweak Banner](./img/just_tweak_banner.png)

# JustTweak

[![Build Status](https://www.bitrise.io/app/375d99516a39bb82/status.svg?token=G7k3kFr7gFKb5y0gzuwH9Q)](https://www.bitrise.io/app/375d99516a39bb82)
[![Version](https://img.shields.io/cocoapods/v/JustTweak.svg?style=flat)](http://cocoapods.org/pods/JustTweak)
[![License](https://img.shields.io/cocoapods/l/JustTweak.svg?style=flat)](http://cocoapods.org/pods/JustTweak)
[![Platform](https://img.shields.io/cocoapods/p/JustTweak.svg?style=flat)](http://cocoapods.org/pods/JustTweak)

JustTweak is a framework for feature flagging, locally and remotely configure and A/B test iOS apps.
It provides a simple interface to creating multiple configurations of Tweaks that you want apply to your app based on some priority.

For example, let's say you want to have a Feature Flag for a feature you're developing and you want to run an A/B test enabling this feature for some of your users using a server based configuration. At the same time you want to force the feature on or off while developing it or to show it working in both cases to your colleagues. Also, you'd like testers and/or Beta users to be able to turn the feature on or off on demand as they use the app without having to ask you.

Using JustTweak achieving this sort of configuration is super simple. All you have to do is add the some information about the tweak in your server based and local Tweaks configuration, and query JustTweak for the value of that Tweak in your code when needed. JustTweak will use the value from the configuration with the highest priority and fallback to the others automatically if no set value is found.

## Usage

```swift
// somewhere in your app, create a TweaksConfigurationsCoordinator
// to inject in the different parts of your app
var configurationsCoordinator: TweaksConfigurationsCoordinator!

private func setUpConfigurations() {
    let jsonFileURL = Bundle.main.url(forResource: "ExampleConfiguration",
                                      withExtension: "json")!
    let jsonConfiguration = JSONTweaksConfiguration(defaultValuesFromJSONAtURL: jsonFileURL)!

    let userDefaults = UserDefaults.standard
    let localConfiguration = UserDefaultsTweaksConfiguration(userDefaults: userDefaults,
                                                             fallbackConfiguration: jsonConfiguration)

    let firebaseConfiguration = FirebaseTweaksConfiguration()

    let configurations: [TweaksConfiguration] = [jsonConfiguration, localConfiguration, firebaseConfiguration]
    configurationsCoordinator = TweaksConfigurationsCoordinator(configurations: configurations)
}

// Later on...
let tweakEnabled = configurationsCoordinator.valueForTweakWith(identifier: "my_tweak")
if tweakEnabled {
    // enable the tweak
} else {
    // disable the tweak if it was enabled
}
```

#### Let the user update a configuration at run time

The Pod also comes with a ViewController to to allow the user to edit the `MutableTweaksConfiguration` with the highest priority.

```swift
// somewhere in a UIViewController...
func presentConfigurationViewController() {
    guard let coordinator = configurationsCoordinator else { return }
    let viewController = TweaksConfigurationViewController(style: .Grouped, configurationsCoordinator: coordinator)
    viewController.title = "Edit Configuration"
    presentViewController(UINavigationController(rootViewController:viewController), animated: true, completion: nil)
}
```

#### Update a configuration at run time yourself

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    updateView()
    NotificationCenter.defaultCenter().addObserver(self,
                                                   selector: #selector(updateView),
                                                   name: ConfigurationDidChangeNotification,
                                                   object: nil)
}

internal func updateView() {
    setUpGesturesIfNeeded()
    redView.hidden = !canShowRedView
    greenView.hidden = !canShowGreenView
    yellowView.hidden = !canShowYellowView
}
```

## Extending JustTweak

JustTweak comes with three default configurations you can immediately startUsing: one for interfacing with UserDefaults, one that takes a JSON file (meant to be the default configuration) and an Ephemenral configuration to use in Unit/UI Tests. Check the example file to see what the JSON scheme looks like.

In addition, JustTweak defines `TweaksConfiguration` and `MutableTweaksConfiguration` as protocols you can implement to create your own configurations to fit your own needs. For example, you can create a configuration that takes its values from services such as Firebase RemoteConfig, Facebook's Tweaks, CloudKit or your own sever.

As a matter of fact, the Example app included in the project, implements a Firebase RemoteConfig based configuration that you can also use in your projects.
Unfortunately it's not currently possible, or non-intuitive at least, to add Firebase as a dependency on this Pod, therefore and that's why we're not including a Firebase configuration by default - however, as you can see from the Podspec, we plan of having an optional subspec to include it.

We also plan to include configurations to support other services, still as optional subspecs. Feel free to open Pull Requests to add services you use.

## Installation

JustTweak is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "JustTweak"
```
## Requirements
JustTweak supports swift 4.0 and Xcode 9

## License

JustTweak is available under the Apache 2.0 license. See the LICENSE file for more info.


- Just Eat iOS team
