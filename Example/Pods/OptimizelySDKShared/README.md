# Objective-C SDK
[![Build Status](https://travis-ci.org/optimizely/objective-c-sdk.svg?branch=master)](https://travis-ci.org/optimizely/objective-c-sdk/)
[![Apache 2.0](https://img.shields.io/github/license/nebula-plugins/gradle-extra-configurations-plugin.svg)](http://www.apache.org/licenses/LICENSE-2.0)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/carthage/carthage)
![Coveralls](https://img.shields.io/coveralls/optimizely/objective-c-sdk.svg)
![Platforms](https://img.shields.io/cocoapods/p/OptimizelySDKiOS.svg)
[![Podspec](https://img.shields.io/cocoapods/v/OptimizelySDKiOS.svg)](https://cocoapods.org/pods/OptimizelySDKiOS)
![Platforms](https://img.shields.io/cocoapods/p/OptimizelySDKTVOS.svg)
[![Podspec](https://img.shields.io/cocoapods/v/OptimizelySDKTVOS.svg)](https://cocoapods.org/pods/OptimizelySDKTVOS)

This repository houses the Objective-C SDK for use with Optimizely Full Stack and Optimizely Rollouts for Mobile and OTT.

Optimizely Full Stack is A/B testing and feature flag management for product development teams. Experiment in any application. Make every feature on your roadmap an opportunity to learn. Learn more at https://www.optimizely.com/platform/full-stack/, or see the [documentation](https://docs.developers.optimizely.com/full-stack/docs).

Optimizely Rollouts is free feature flags for development teams. Easily roll out and roll back features in any application without code deploys. Mitigate risk for every feature on your roadmap. Learn more at https://www.optimizely.com/rollouts/, or see the [documentation](https://docs.developers.optimizely.com/rollouts/docs).

## Getting Started

### Using the SDK

See the [Mobile developer documentation](https://developers.optimizely.com/x/solutions/sdks/reference/index.html?language=objectivec&platform=mobile) or [OTT developer documentation](https://developers.optimizely.com/x/solutions/sdks/reference/index.html?language=objectivec&platform=ott) to learn how to set
up an Optimizely X project and start using the SDK.

### Requirements
* iOS 8.0+ / tvOS 9.0+

### Installing the SDK
 
Please note below that _\<platform\>_ is used to represent the platform on which you are building your app. Currently, we support ```iOS``` and ```tvOS``` platforms.

**note: if you or another framework are using sqlite, then you should probably add compiler options for thead safe sqlite: SQLITE_THREADSAFE=1
https://www.sqlite.org/threadsafe.html

#### Cocoapod 
1. Add the following lines to the _Podfile_:<pre>
    ```use_frameworks!```
    ```pod 'OptimizelySDK<platform>', '~> 3.1.0'```
</pre>

2. Run the following command: <pre>``` pod install ```</pre>

Further installation instructions for Cocoapods: https://guides.cocoapods.org/using/getting-started.html

#### Carthage
1. Add the following lines to the _Cartfile_:<pre> 
github "optimizely/objective-c-sdk" ~> 3.1.0
</pre>

2. Run the following command:<pre>```carthage update```</pre>

3. Link the frameworks to your project. Go to your project target's **Link Binary With Libraries** and drag over the following from the _Carthage/Build/\<platform\>_ folder: <pre> 
      OptimizelySDKCore.framework
      OptimizelySDKDatafileManager.framework
      OptimizelySDKEventDispatcher.framework
      OptimizelySDKShared.framework
      OptimizelySDKUserProfileService.framework
      OptimizelySDK\<platform\>.framework</pre>

4. To ensure that proper bitcode-related files and dSYMs are copied when archiving your app, you will need to install a Carthage build script:
      - Add a new **Run Script** phase in your target's **Build Phase**.</br>
      - In the script area include:<pre>
      ```/usr/local/bin/carthage copy-frameworks```</pre> 
      - Add the paths to the frameworks to the **Input Files** list:<pre>
            ```$(SRCROOT)/Carthage/Build/<platform>/OptimizelySDKCore.framework```
            ```$(SRCROOT)/Carthage/Build/<platform>/OptimizelySDKDatafileManager.framework```
            ```$(SRCROOT)/Carthage/Build/<platform>/OptimizelySDKEventDispatcher.framework```
            ```$(SRCROOT)/Carthage/Build/<platform>/OptimizelySDKShared.framework```
            ```$(SRCROOT)/Carthage/Build/<platform>/OptimizelySDKUserProfileService.framework```
            ```$(SRCROOT)/Carthage/Build/<platform>/OptimizelySDK<platform>.framework```</pre>
      - Add the paths to the copied frameworks to the **Output Files** list:<pre>
            ```$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/OptimizelySDKCore.framework```
            ```$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/OptimizelySDKDatafileManager.framework```
            ```$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/OptimizelySDKEventDispatcher.framework```
            ```$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/OptimizelySDKShared.framework```
            ```$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/OptimizelySDKUserProfileService.framework```
            ```$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/OptimizelySDK<platform>.framework```</pre>

Futher installation instructions for Carthage: https://github.com/Carthage/Carthage

#### Manual Installation

The universal framework can be used in an application without the need for a third-party dependency manager. The universal framework packages up all Optimizely X Mobile modules, which include:<pre>
	```OptimizelySDKCore```
	```OptimizelySDKShared```
	```OptimizelySDKDatafileManager```
	```OptimizelySDKEventDispatcher```
	```OptimizelySDKUserProfileService```</pre>

The universal framework for iOS includes builds for the following architectures:<pre>
	```i386```
	```x86_64```
	```ARMv7```
	```ARMv7s```
	```ARM64```</pre>

The universal framework for tvOS includes builds for the following architectures:<pre>
	```x86_64```
	```ARM64```</pre>

Bitcode is enabled for both the iOS and tvOS universal frameworks. 

In order to install the universal framework, follow the steps below:

1. Download the [iOS](./OptimizelySDKUniversal/generated-frameworks/Release-iOS-universal-SDK/OptimizelySDKiOS.framework.zip) or [tvOS](./OptimizelySDKUniversal/generated-frameworks/Release-tvOS-universal-SDK/OptimizelySDKTVOS.framework.zip) framework.

2. Unzip the framework, then drag the framework to your project in Xcode; Xcode should prompt you to select a target. Go to **Build Phases** and make sure that the framework is under the **Link Binary with Libraries** section.
 
3. Go to the **General** tab and add the framework to the **Embedded Binaries** section. If the **Embedded Binaries** section is not visible, add the framework in the **Copy Files** section (you can add this section in **Build Settings**).

4. The Apple store will reject your app if you have the universal framework installed as it includes simulator binaries. Therefore, a script to strip the extra binaries needs to be run before you upload the app. To do this, go to **Build Phases** and add a **Run Script** section by clicking the ```+``` symbol. Copy and paste the following script (make sure you replace the ```FRAMEWORK_NAME``` with the proper framework name!
):
	 ```
	FRAMEWORK="FRAMEWORK_NAME"
	FRAMEWORK_EXECUTABLE_PATH="${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/$FRAMEWORK.framework/$FRAMEWORK"
	EXTRACTED_ARCHS=()
	for ARCH in $ARCHS
	do
		lipo -extract "$ARCH" "$FRAMEWORK_EXECUTABLE_PATH" -o "$FRAMEWORK_EXECUTABLE_PATH-$ARCH"
		EXTRACTED_ARCHS+=("$FRAMEWORK_EXECUTABLE_PATH-$ARCH")
	done
	lipo -o "$FRAMEWORK_EXECUTABLE_PATH-merged" -create "${EXTRACTED_ARCHS[@]}"
	rm "${EXTRACTED_ARCHS[@]}"
	rm "$FRAMEWORK_EXECUTABLE_PATH"
	mv "$FRAMEWORK_EXECUTABLE_PATH-merged" "$FRAMEWORK_EXECUTABLE_PATH"
	```
If you choose to build the universal framework yourself, you can do so by running the ```OptimizelySDKiOS-Universal``` or ```OptimizelySDKTVOS-Universal``` schemes. After building these schemes, the frameworks are output in the **OptimizelySDKUniversal/generated-frameworks** folder.

### Contributing
Please see [CONTRIBUTING](CONTRIBUTING.md).

### Credits

First-party code (under OptimizelySDKCore/, OptimizelySDKDatafileManager/, OptimizelySDKEventDispatcher/, OptimizelySDKiOS/, OptimizelySDKShared/, OptimizelySDKTVOS/, OptimizelySDKUniversal/, OptimizelySDKUserProfileService/, ) is copyright Optimizely, Inc. and contributors, licensed under Apache 2.0.

### Additional Code

**FMDB** [https://github.com/ccgus/fmdb](https://github.com/ccgus/fmdb)  
License (MIT):: [https://github.com/ccgus/fmdb/blob/master/LICENSE.txt](https://github.com/ccgus/fmdb/blob/master/LICENSE.txt)
Modfied: Yes
Distributed: Yes
Distribution: Binary

**SQLITE3** [https://www.sqlite.org/index.html](https://www.sqlite.org/index.html)  
License (Public Domain):: [https://www.sqlite.org/copyright.html](https://www.sqlite.org/copyright.html)
Modfied: Yes
Distributed: Yes
Distribution: Binary

**JSONModel** [https://github.com/jsonmodel/jsonmodel](https://github.com/jsonmodel/jsonmodel)  
License (MIT):: [https://github.com/jsonmodel/jsonmodel/blob/master/LICENSEl](https://github.com/jsonmodel/jsonmodel/blob/master/LICENSE)
Modfied: Yes
Distributed: Yes
Distribution: Binary

**murmur3** [https://github.com/PeterScott/murmur3l](https://github.com/PeterScott/murmur3)  
License (Public Domain):: [https://github.com/PeterScott/murmur3l](https://github.com/PeterScott/murmur3)
Modfied: No
Distributed: Yes
Distribution: Binary
