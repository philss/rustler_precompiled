# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/philss/rustler_precompiled/compare/v0.5.0...HEAD
[0.5.0]: https://github.com/philss/rustler_precompiled/compare/v0.4.1...v0.5.0
[0.4.1]: https://github.com/philss/rustler_precompiled/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/philss/rustler_precompiled/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/philss/rustler_precompiled/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/philss/rustler_precompiled/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/philss/rustler_precompiled/releases/tag/v0.1.0
