# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.7.2] - 2024-06-26

### Added

- The `RUSTLER_PRECOMPILED_GLOBAL_CACHE_PATH` environment variable was added to enable
  an easy way to configure a directory to fetch the artifacts before reaching the internet.
  This is useful to make more predictable where the cache files will be located, thus
  enabling users to use that directory as a repository for the artifacts.
  This env var will affect all packages using this library.

 - Add the `RUSTLER_PRECOMPILED_FORCE_BUILD_ALL` env var to force the build of all packages
   using RustlerPrecompiled. Be aware that `Rustler` will be required if this is set
   to `1` or `true`. There is a new application env that has precedence over the env var,
   which is the `:force_build_all`.

### Changed

- Automatically run the "app.config" mix task in the "rustler_precompiled.download" mix task.

  This will trigger the project compilation and configuration, but will not start the app.
  It's necessary to check if the module passed to the task exists or not.

  You can deactivate this behaviour by passing the flag `--no-config` to that mix task.
  The mix task "rustler_precompiled.download" is used in the step of publishing a package.

- Stop throwing an error in case the metadata cannot be written.
  This is because metadata is only necessary in the process of publishing the package,
  and users may be running with "write" permission restrictions.
  We now print a warning instead.

### Fixed

- Restrict the change of vendor to "unknown" only if the target is a Linux system.

## [0.7.1] - 2023-11-30

### Fixed

- Fix the URL for variants on download.

## [0.7.0] - 2023-09-22

### Added

- Add `:max_retries` option, to control how many times we should try
  to download a NIF artifact. By default it is going to try 3 times.
  To disable this feature, use the value `0`.

- Add support for variants. This is a feature that enables building
  for the same target with multiple configurations. It can support
  different features or OS dependencies. The selection is done in
  compile time.

### Changed

- Change default list of NIF versions to only include the version `2.15`.
  This is because most of the users won't need to activate newer versions,
  unless they use features from those versions.

  This is going to simplify and speed up the release process for most of the
  projects.

## [0.6.3] - 2023-08-28

### Fixed

- Make sure `:nif_versions` option is respected.

  This is a small bug fix that was blocking the usage of a more
  restrict list of "NIF versions". For example, if my system is
  using NIF version 2.16, but I want to be compatible with only
  version 2.15, this was being ignored, since the algorithm for
  finding compatible versions was not taking into account this
  restriction.

## [0.6.2] - 2023-07-05

### Added

- Add support for FreeBSD as a target.

### Changed

- Remove `:crypto` from the extra applications list, because `:ssl` already includes it.

- Update the guide to mention the new way to select a NIF version in Rustler >= 0.29.

## [0.6.1] - 2023-02-16

### Changed

- Depend on `:ssl` instead of `:public_key` application. Since `:public_key` is started
  with `:ssl`, this shouldn't break. This change is needed in order to support the upcoming
  Elixir 1.15.

## [0.6.0] - 2023-01-27

### Added

- Add support for configuring the NIF versions that the project supports.
  This can be done with the `:nif_versions` config.

- Add support for `castore` version `~> 1.0`.

### Changed

- Add `aarch64-unknown-linux-musl` and `riscv64gc-unknown-linux-gnu` as default targets.
  The first one is common for people running Linux containers that were built with Musl on Apple computers.
  The second one is becoming popular for tiny computers, normally running Nerves.

  The adoption of these targets can increase a little bit the compilation time, but
  can affect a great number of users.

  For package maintainers: please remember to add these targets to your CI workflow.
  See an example workflow at: https://github.com/philss/rustler_precompilation_example/blob/main/.github/workflows/release.yml

- Change the depth of SSL peer verification to "3". This should be more compatible with servers.

- Remove version "2.14" from the default NIF versions. Like the change of default targets,
  this should only have effect in the moment of release of a new package version.
  Remember to update your workflow file.

## [0.5.5] - 2022-12-10

### Fixed

- Add support for Suse Linux targets. This is a fix to the plataform resolution. Thanks [@fabriziosestito](https://github.com/fabriziosestito).
- Fix validation of HTTP proxy. This makes the validation similar to the HTTPS proxy. Thanks [@w0rd-driven](https://github.com/w0rd-driven).
- Map `riscv64` to `riscv64gc` to match Rust naming. Thanks [@fhunleth](https://github.com/fhunleth).

## [0.5.4] - 2022-11-05

### Fixed

- Fix building metadata when "force build" is enabled and the target is not available.

## [0.5.3] - 2022-10-19

### Fixed

- Always write the metadata file in compilation time, so mix tasks can work smoothly.

## [0.5.2] - 2022-10-03

### Fixed

- Fix the `target/0` function to use default targets a default argument. This makes the example
  in the docs work again. Thanks [@jackalcooper](https://github.com/jackalcooper).
- Only use proxy if it is valid. Thanks [@josevalim](https://github.com/josevalim).
- Fix the support for PCs running RedHat Linux. Thanks [@Benjamin-Philip](https://github.com/Benjamin-Philip).
- Improve some points in the docs. Thanks [@whatyouhide](https://github.com/whatyouhide) and [@fabriziosestito](https://github.com/fabriziosestito).

## [0.5.1] - 2022-05-24

### Fixed

- Fix available targets naming to include the NIF version in the name. It was removed accidentally.
  Thanks [@adriankumpf](https://github.com/adriankumpf).

## [0.5.0] - 2022-05-24

### Added

- Now it's possible to configure the targets list, based in the [Rust's Plataform Support](https://doc.rust-lang.org/stable/rustc/platform-support.html)
  list. You can run `rustc --print target-list` to get the full list.
  Thanks [@adriankumpf](https://github.com/adriankumpf).

### Changed

- The precompilation guide was improved with instructions and suggestions for the `files` key at
  the project config.
  Thanks [@nbw](https://github.com/nbw).
- Now we raise with a different error if the NIF artifact cannot be written when downloading to create
  the checksum file.

## [0.4.1] - 2022-04-28

### Fixed

- Fix `__using__` macro for when Rustler is not loaded.

## [0.4.0] - 2022-04-28

### Changed

- Make Rustler an optional dependency. This makes installation faster for most of the users.

## [0.3.0] - 2022-03-26

### Added

- Add the possibility to skip the download of unavailable NIFs when generating the
  checksum file - thanks [@fahchen](https://github.com/fahchen)

## [0.2.0] - 2022-02-18

### Fixed

- Fix validation of URL in order to be compatible with Elixir ~> 1.11.
  The previous implementation was restricted to Elixir ~> 1.13.

### Added

- Add `:force_build` option that fallback to `Rustler`. It passes all options
  except the ones used by `RustlerPrecompiled` down to `Rustler`.
  This option will be by default `false`, but if the project is using a pre-release,
  then it will always be set to `true`.
  With this change the project starts depending on Rustler.

### Changed

- Relax dependencies to the minor versions.

## [0.1.0] - 2022-02-16

### Added

- Add basic features to download and use the precompiled NIFs in a safe way.

[Unreleased]: https://github.com/philss/rustler_precompiled/compare/v0.7.2...HEAD
[0.7.2]: https://github.com/philss/rustler_precompiled/compare/v0.7.1...v0.7.2
[0.7.1]: https://github.com/philss/rustler_precompiled/compare/v0.7.0...v0.7.1
[0.7.0]: https://github.com/philss/rustler_precompiled/compare/v0.6.3...v0.7.0
[0.6.3]: https://github.com/philss/rustler_precompiled/compare/v0.6.2...v0.6.3
[0.6.2]: https://github.com/philss/rustler_precompiled/compare/v0.6.1...v0.6.2
[0.6.1]: https://github.com/philss/rustler_precompiled/compare/v0.6.0...v0.6.1
[0.6.0]: https://github.com/philss/rustler_precompiled/compare/v0.5.5...v0.6.0
[0.5.5]: https://github.com/philss/rustler_precompiled/compare/v0.5.4...v0.5.5
[0.5.4]: https://github.com/philss/rustler_precompiled/compare/v0.5.3...v0.5.4
[0.5.3]: https://github.com/philss/rustler_precompiled/compare/v0.5.2...v0.5.3
[0.5.2]: https://github.com/philss/rustler_precompiled/compare/v0.5.1...v0.5.2
[0.5.1]: https://github.com/philss/rustler_precompiled/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/philss/rustler_precompiled/compare/v0.4.1...v0.5.0
[0.4.1]: https://github.com/philss/rustler_precompiled/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/philss/rustler_precompiled/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/philss/rustler_precompiled/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/philss/rustler_precompiled/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/philss/rustler_precompiled/releases/tag/v0.1.0
