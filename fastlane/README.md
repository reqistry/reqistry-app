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

### android validate_play

```sh
[bundle exec] fastlane android validate_play
```

Validate Google Play service-account access

### android internal

```sh
[bundle exec] fastlane android internal
```

Build and publish to the internal testing track

### android metadata

```sh
[bundle exec] fastlane android metadata
```

Upload localized Play Store listings and images only

### android production

```sh
[bundle exec] fastlane android production
```

Build and upload production release (draft by default)

### android status

```sh
[bundle exec] fastlane android status
```

Read-only Play track/release/tester inventory (no changes)

### android retire_locales

```sh
[bundle exec] fastlane android retire_locales
```

Delete remote Play listings except en-US + es-ES (backup in /tmp/opencode/play-backup-20260920)

### android retire_test_tracks

```sh
[bundle exec] fastlane android retire_test_tracks
```

Empty obsolete beta/alpha test tracks (keeps internal QA + production)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
