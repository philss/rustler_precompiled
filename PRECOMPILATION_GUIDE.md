# Precompilation guide

Rustler provides an easy way to use safer NIFs in OTP applications. But in some
environments it's harder to use the benefits of the tool because every user
needs to install the Rust toolchain and compile the project,
which can take several minutes in some cases.

This changes with the help of the `RustlerPrecompiled` package. Now we can easily
use precompiled Rustler NIFs from an external source.

The precompilation happens in a CI server, always in a transparent way, and
the Hex package published should always include a checksum file to ensure
the NIFs stays the same, therefore avoiding supply chain attacks.

In this guide I will show you how to prepare your project to use this feature.

## Prepare for the build

Most of the work is done in the CI server. In this example we are going to use GitHub Actions.

The GH Actions service has the benefit of hosting artifacts for releases and make them
public available.

### Configure Github Actions

In order for the workflow to succeed, read and write permissions will need to be enabled for the
repository.

1. Settings > Actions > General
2. Workflow permissions
3. Check the box "Read and write permissions"

### Configure Targets

Usually we want to build for the most popular targets and the three last NIF versions. NIF versions
are more stable than OTP versions because they only change after two major releases of OTP.

For this guide our targets will be the following:

- OS: Linux, Windows, macOS
- Architectures: `x86_64`, `aarch64` (ARM 64 bits), `arm`
- NIF versions: `2.14`, `2.15`, `2.16`.

In summary the build matrix looks like this:

```yaml
matrix:
  nif: ["2.16", "2.15", "2.14"]
  job:
    - { target: arm-unknown-linux-gnueabihf , os: ubuntu-20.04 , use-cross: true }
    - { target: aarch64-unknown-linux-gnu   , os: ubuntu-20.04 , use-cross: true }
    - { target: aarch64-apple-darwin        , os: macos-11      }
    - { target: x86_64-apple-darwin         , os: macos-11      }
    - { target: x86_64-unknown-linux-gnu    , os: ubuntu-20.04  }
    - { target: x86_64-unknown-linux-musl   , os: ubuntu-20.04 , use-cross: true }
    - { target: x86_64-pc-windows-gnu       , os: windows-2019  }
    - { target: x86_64-pc-windows-msvc      , os: windows-2019  }
```

A complete workflow example can be found in the [`rustler_precompilation_example`](https://github.com/philss/rustler_precompilation_example/blob/main/.github/workflows/release.yml) project.

## Additional configuration before build

In our build we are going to cross compile our crate project (the Rust code for our NIF) using
a variety of targets as we saw in the previous section. For this to work we need to guide the Rust
compiler in some cases by providing additional configuration in the `.cargo/config` file of our project.

Here is an example of that file:

```toml
[target.'cfg(target_os = "macos")']
rustflags = [
  "-C", "link-arg=-undefined",
  "-C", "link-arg=dynamic_lookup",
]

# See https://github.com/rust-lang/rust/issues/59302
[target.x86_64-unknown-linux-musl]
rustflags = [
  "-C", "target-feature=-crt-static"
]

# Provides a small build size, but takes more time to build.
[profile.release]
lto = true
```

In addition to that, we also use a tool called [`cross`](https://github.com/rust-embedded/cross) that
makes the build easier for some targets (the ones using `use-cross: true` in our example).

## The Rustler module

We need to tell `RustlerPrecompiled` where to find our NIF files, and we need to tell which version to use.

```elixir
defmodule RustlerPrecompilationExample.Native do
  version = Mix.Project.config()[:version]

  use RustlerPrecompiled,
    otp_app: :rustler_precompilation_example,
    crate: "example",
    base_url:
      "https://github.com/philss/rustler_precompilation_example/releases/download/v#{version}",
    force_build: System.get_env("RUSTLER_PRECOMPILATION_EXAMPLE_BUILD") in ["1", "true"],
    version: version

  # When your NIF is loaded, it will override this function.
  def add(_a, _b), do: :erlang.nif_error(:nif_not_loaded)
end
```

This example was extracted from the [`rustler_precompilation_example`](https://github.com/philss/rustler_precompilation_example/blob/main/lib/rustler_precompilation_example/native.ex) project.
RustlerPrecompiled will try to figure out the target and download the correct file for us. This will happen in compile
time only.

Optionally it's possible to force the compilation by setting an env var, like the example suggests.
It's also possible to force the build by using a pre release version, like `0.1.0-dev`. The only
requirement to force the build is to have Rustler declared as a dependency as well:
`{:rustler, ">= 0.0.0", optional: true}`.

## The release flow

### Generating a checksum file

In a scenario where you need to release a Hex package using precompiled NIFs, you first need to
build the release in the CI, wait for all artifacts to be available and then generate
the **checksum file** that is **MANDATORY** for your package to work.

This checksum file is generated by running the following command after the build is complete:

    $ mix rustler_precompiled.download YourRustlerModule --all --print

With the module I used for this guide, the command would be:

    $ mix rustler_precompiled.download RustlerPrecompilationExample.Native --all --print

The file generated will be named `checksum-Elixir.RustlerPrecompilationExample.Native.exs` and
it's extremely important that you include this file in your Hex package (by updating the `files:`
field in your `mix.exs`). Otherwise your package **won't work**. Your `files:` key at your
package configuration will look like this:

```elixir
defp package do
  [
    files: [
      "lib",
      "native",
      "checksum-*.exs",
      "mix.exs"
    ],
    // ...
  ]
end
```

Note: you don't need to track the checksum file in your version control system (git or other).

For an example, refer to the `mix.exs` file of the [rustler precompilation example](https://github.com/philss/rustler_precompilation_example/blob/main/mix.exs)
or elixir-nx's [explorer](https://github.com/elixir-nx/explorer/blob/723eea63204e43bc9238d2488fd355f17a1e13f2/mix.exs#L65-L72) library.

Tip: use the `mix hex.build --unpack` command to confirm which files are being included (and if the package looks good before publishing).

### Recommended flow

To recap, the suggested flow is the following:

1. release a new tag
2. push the code to your repository with the new tag: `git push origin main --tags`
3. wait for all NIFs to be built
4. run the `mix rustler_precompiled.download` task (with the flag `--all`)
5. release the package to Hex.pm (make sure your release includes the correct files).

## Conclusion

The ability to use precompiled NIFs written in Rust can increase the adoption of some packages,
because people won't need to have Rust installed. But this comes with some drawbacks and more
responsibilities to the maintainers, so use this feature carefully.
