# Developing the Client

## Introduction

This is the source code for the Expo client app used to view projects published to the Expo service. If you want to build and install the Expo client directly onto a device, you're in the right place. Note that if you just want to install the Expo client app on a simulator, you do not need to build it from source. Instead, you should [follow the instructions here](https://docs.expo.io/versions/latest/introduction/installation.html).

To build the Expo client app, follow the instructions in the [Setup](#setup) section below. Use the [Expo CLI](https://docs.expo.io/versions/latest/workflow/expo-cli) to use Expo's infrastructure to build your app.

Please ask us on the [forums](https://forums.expo.io/) if you get stuck.

**Disclaimers:**

If you want to build a standalone app that has a custom icon and name, see [our documentation here](https://docs.expo.io/versions/latest/distribution/building-standalone-apps/). You're in the wrong place and you shouldn't need to build the Expo clients from source.

If you need to make native code changes to your Expo project, such as adding custom native modules, we can [generate a native project for you](https://docs.expo.io/versions/latest/expokit/eject). You're in the wrong place and you shouldn't need to build the Expo clients from source.

## Configuring your environment

Note: We support building the clients only on macOS.

- Install [nix](https://nixos.org/nix) (currently `curl https://nixos.org/nix/install | sh`)
- Install [direnv](http://direnv.net/) (to do this with nix, run `nix-env -iA nixpkgs.direnv`)
- Clone this repo; we recommend cloning it to a directory whose full path does not include any spaces (you should clone all the submodules with `git clone --recurse-submodules`)
- Run `yarn` in the root and `tools-public` directories.
- Run `yarn build` in the `packages/expo` directory.

### iOS

- Make sure you have latest non-beta Xcode installed.
- Run `git lfs pull`.
- Run `et ios-generate-dynamic-macros`.
- Open and run `ios/Exponent.xcworkspace` in Xcode.

### Android

- Make sure you have Android Studio 3 installed
- Run `android/install-ndk-17c.sh` to get the required version of the Android NDK.
- See "Running on a Device"

## Running on a Device

### iOS

- In Xcode's menu bar, open the **Xcode** drop-down menu, and select **Preferences**. Then in the **Accounts** tab of the preferences menu, add your personal or team apple developer account.
- Connect your test device to your computer with a USB cable.
- In Xcode's menu bar, open the **Product** drop-down menu, select **Destination**, then in the _Device_ grouping select your device.
- In the project navigator, select the **Exponent** project to bring up the project's settings, and then:
  - In the **General** tab, in the **Identity** section, put in a unique Bundle Identifier.
  - Also in the **General** tab, in the **Signing** section, select your personal or team apple developer account as your **Team**, and create a new signing certificate by clicking **Fix Issue**.
- Finally, run the build

### Android

- If the Play Store version of the Expo Client App is installed on your test device, uninstall it.
- Connect your test device to your computer with a USB cable.
- Run `fastlane android start`, or alternately open the `android` directory in Android Studio, start it, and in the **Select Deployment Target** dialog, select your device.

## Standalone Apps

If you don't need custom native code outside of the Expo SDK, head over to [our documentation on building standalone apps without needing Android Studio and Xcode](https://docs.expo.io/versions/latest/distribution/building-standalone-apps/).

If you need standalone apps as built by running `expo build:ios` or `expo build:android` for a supported SDK version, check out our docs on [using turtle-cli to build apps locally or on CI](https://docs.expo.io/versions/latest/distribution/turtle-cli/).

If you're still here, you need to build a standalone app with code currently on `master` or another unreleased branch. Make sure to follow the [Configure app.json](https://docs.expo.io/versions/latest/distribution/building-standalone-apps/#2-configure-appjson) section of the docs before continuing. You'll need to add the appropriate fields to your `app.json` before the standalone app scripts can run. Once that's done, continue on to the platform-specific instructions.

### Android

The Android standalone app script creates a new directory `android-shell-app` with the modified Android project in it. It then compiles that new directory giving you a signed or unsigned `.apk` depending on whether you provide a keystore and the necessary passwords. If there are issues with the app you can open the `android-shell-app` project in Android Studio to debug.

Here are the steps to build a standalone Android app:

- Publish your experience with Expo CLI. Note the published URL.
- If you want a signed `.apk`, run `et android-shell-app --url [the published experience url] --sdkVersion [sdk version of your experience] --keystore [path to keystore] --alias [keystore alias] --keystorePassword [keystore password] --keyPassword [key password]`.
- If you don't want a signed `.apk`, run `et android-shell-app --url [the published experience url] --sdkVersion [sdk version of your experience]`.
- The `.apk` file will be at `/tmp/shell-signed.apk` for a signed `.apk` or at `/tmp/shell-debug.apk` for an unsigned `.apk`.

### iOS

The iOS standalone app script has two actions, `build` and `configure`. `build` creates an archive or a simulator build of the Expo iOS workspace. `configure` accepts a path to an existing archive and modifies all its configuration files so that it will run as a standalone Expo experience rather than as the Expo client app.

Here are the steps to build a standalone iOS app:

- Publish your experience with Expo CLI. Note the published URL.
- `cd tools-public`.
- `gulp ios-shell-app --action build --type [simulator or archive] --configuration [Debug or Release]`
- The resulting archive will be created at `../shellAppBase-[type]`.
- `gulp ios-shell-app --url [the published experience url] --action configure --type [simulator or archive] --archivePath [path to ExpoKitApp.app] --sdkVersion [sdk version of your experience] --output your-app.tar.gz`
- This bundle is not signed and cannot be submitted to iTunes Connect as-is; you'll need to manually sign it if you'd like to submit it to Apple. [Fastlane](https://fastlane.tools/) is a good option for this. Also, [Expo will do this for you](https://docs.expo.io/versions/latest/distribution/building-standalone-apps/) if you don't need to build this project from source.
- If you created a simulator build in the first step, unpack the tar.gz using `tar -xvzf your-app.tar.gz`. Then you can run this on iPhone Simulator using `xcrun simctl install booted <app path>` and `xcrun simctl launch booted <app identifier>`. Another alternative which some people prefer is to install the [ios-sim](https://github.com/phonegap/ios-sim) tool and then use `ios-sim launch <app path>`.
- There are a few more optional flags you can pass to this script. They are all documented in the block comments inside `xdl/src/detach/IosShellApp.js`.

## Modifying JS Code

The Expo client apps run a root Expo project in addition to native code. By default this will use a published version of the project, so any changes made in the `home` directory will not show up without some extra work.

Serve this project locally by running `expo start` from the `home` directory. On iOS, you'll additionally need to set `DEV_KERNEL_SOURCE` to `LOCAL` in `EXBuildConstants.plist` (the default is `PUBLISHED`).

The native Android Studio and XCode projects have a build hook which will find this if `expo start` is running. Keep this running and rebuild the app on each platform.

## Tests

### iOS

For native XCTest unit tests:

- Press Command+U in XCode to build and test the `Tests` unit test target.
- Alternatively, run `fastlane ios test` from the parent directory of `ios`.

For JS integration tests, test the `ExponentIntegrationTests` target (not included in the default test scheme). This target requires you to configure `EXTestEnvironment.plist` with a key `testSuiteUrl` whose value is the URL to load some version of Expo's [test-suite](apps/test-suite) app. This will run a bunch of Jasmine tests against the Expo SDK.