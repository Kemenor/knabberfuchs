fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## Android

### android validate

```sh
[bundle exec] fastlane android validate
```

Validate the metadata locally — no upload, catches length/format errors

### android listing

```sh
[bundle exec] fastlane android listing
```

Push store listing text + screenshots only (no binary) as a draft

### android internal

```sh
[bundle exec] fastlane android internal
```

Upload the release AAB to the internal testing track as a draft

----


## iOS

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Upload the built IPA to TestFlight (run `flutter build ipa` first)

### ios listing

```sh
[bundle exec] fastlane ios listing
```

Push App Store listing text (no binary, no screenshots) — staged, not submitted

### ios screenshots

```sh
[bundle exec] fastlane ios screenshots
```

Replace the App Store screenshots with the repo set (overwrites all — fixes dupes)

### ios release

```sh
[bundle exec] fastlane ios release
```

Submit an uploaded TestFlight build for App Store review (auto-release on approval)

### ios validate

```sh
[bundle exec] fastlane ios validate
```

Validate the App Store metadata locally — no upload

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
