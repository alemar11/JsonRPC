[![Swift 4.0.2](https://img.shields.io/badge/Swift-4.0.2-orange.svg?style=flat)](https://developer.apple.com/swift)
![Platforms](https://img.shields.io/badge/Platform-iOS%2010%2B%20|%20macOS%2010.12+%20|%20tvOS%2010+%20|%20watchOS%203+|%20Ubuntu%20Linux-blue.svg) 

[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/JsonRPC.svg)](https://cocoapods.org/pods/JsonRPC)

## JsonRPC
[![GitHub release](https://img.shields.io/github/release/tinrobots/JsonRPC.svg)](https://github.com/tinrobots/JsonRPC/releases)

Work in progress...

- [Requirements](#requirements)
- [Documentation](#documentation)
- [Installation](#installation)
- [License](#license)

## Requirements

- iOS 10.0+ / macOS 10.12+ / tvOS 10.0+ / watchOS 3.0+
- Xcode 9.0
- Swift 4.0.2

## Documentation

Documentation is [available online](http://www.tinrobots.org/JsonRPC/).

> [http://www.tinrobots.org/JsonRPC/](http://www.tinrobots.org/JsonRPC/)

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.1.0+ is required to build JsonRPC 1.0.0+.

To integrate JsonRPC into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'JsonRPC', '~> 1.0'
end
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate JsonRPC into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "tinrobots/JsonRPC" ~> 1.0.0
```

Run `carthage update` to build the framework and drag the built `JsonRPC.framework` into your Xcode project.

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. 
Once you have your Swift package set up, adding JsonRPC as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/tinrobots/JsonRPC.git", from: "1.0.0")
]
```

### Manually

If you prefer not to use either of the aforementioned dependency managers, you can integrate JsonRPC into your project manually.

#### Embedded Framework

- Open up Terminal, `cd` into your top-level project directory, and run the following command "if" your project is not initialized as a git repository:

```bash
$ git init
```

- Add JsonRPC as a git [submodule](http://git-scm.com/docs/git-submodule) by running the following command:

```bash
$ git submodule add https://github.com/tinrobots/JsonRPC.git
```

- Open the new `JsonRPC` folder, and drag the `JsonRPC.xcodeproj` into the Project Navigator of your application's Xcode project.

    > It should appear nested underneath your application's blue project icon. Whether it is above or below all the other Xcode groups does not matter.

- Select the `JsonRPC.xcodeproj` in the Project Navigator and verify the deployment target matches that of your application target.
- Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.
- In the tab bar at the top of that window, open the "General" panel.
- Click on the `+` button under the "Embedded Binaries" section.
- You will see two different `JsonRPC.xcodeproj` folders each with two different versions of the `JsonRPC.framework` nested inside a `Products` folder.

    > It does not matter which `Products` folder you choose from, but it does matter whether you choose the top or bottom `JsonRPC.framework`.

- Select the top `JsonRPC.framework` for iOS and the bottom one for macOS.

    > You can verify which one you selected by inspecting the build log for your project. The build target for `JsonRPC` will be listed as either `JsonRPC iOS`, `JsonRPC macOS`, `JsonRPC tvOS` or `JsonRPC watchOS`.


## License

[![License MIT](https://img.shields.io/badge/License-MIT-lightgrey.svg?style=flat)](https://github.com/alemar11/Console/blob/master/LICENSE)

JsonRPC is released under the MIT license. See [LICENSE](./LICENSE.md) for details.
