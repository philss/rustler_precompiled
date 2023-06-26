defmodule RustlerPrecompiled.ConfigTest do
  use ExUnit.Case, async: true

  alias RustlerPrecompiled.Config

  test "new/1 sets `force_build?` to true when pre-release version is used" do
    config =
      Config.new(
        otp_app: :rustler_precompiled,
        module: RustlerPrecompilationExample.Native,
        base_url:
          "https://github.com/philss/rustler_precompilation_example/releases/download/v0.2.0",
        version: "0.2.0-dev"
      )

    assert config.force_build?
  end

  test "new/1 sets `force_build?` when configured" do
    config =
      Config.new(
        otp_app: :rustler_precompiled,
        module: RustlerPrecompilationExample.Native,
        base_url:
          "https://github.com/philss/rustler_precompilation_example/releases/download/v0.2.0",
        force_build: true,
        version: "0.2.0"
      )

    assert config.force_build?
  end

  test "new/1 requires `force_build` option when is not a pre-release" do
    assert_raise KeyError, ~r/key :force_build not found/, fn ->
      Config.new(
        otp_app: :rustler_precompiled,
        module: RustlerPrecompilationExample.Native,
        base_url:
          "https://github.com/philss/rustler_precompilation_example/releases/download/v0.2.0",
        version: "0.2.0"
      )
    end
  end

  test "new/1 validates the given targets" do
    opts = [
      otp_app: :rustler_precompiled,
      module: RustlerPrecompilationExample.Native,
      base_url:
        "https://github.com/philss/rustler_precompilation_example/releases/download/v0.2.0",
      version: "0.2.0-dev"
    ]

    assert_raise RuntimeError,
                 "`:targets` is required to be a list of supported targets",
                 fn ->
                   Config.new(opts ++ [targets: "aarch64-unknown-linux-gnu"])
                 end

    assert_raise RuntimeError,
                 "`:targets` is required for `RustlerPrecompiled`",
                 fn ->
                   Config.new(opts ++ [targets: nil])
                 end

    assert_raise RuntimeError,
                 """
                 `:targets` contains targets that are not supported:

                 ["aarch64-unknown-linux-foo"]
                 """,
                 fn ->
                   Config.new(
                     opts ++
                       [
                         targets: [
                           "aarch64-unknown-linux-gnu",
                           "aarch64-unknown-linux-gnu_ilp32",
                           "aarch64-unknown-linux-musl",
                           "aarch64-unknown-linux-foo"
                         ]
                       ]
                   )
                 end
  end

  test "new/1 configures a set of default targets" do
    config =
      Config.new(
        otp_app: :rustler_precompiled,
        module: RustlerPrecompilationExample.Native,
        base_url:
          "https://github.com/philss/rustler_precompilation_example/releases/download/v0.2.0",
        version: "0.2.0-dev"
      )

    assert config.targets == [
             "aarch64-apple-darwin",
             "aarch64-unknown-linux-gnu",
             "aarch64-unknown-linux-musl",
             "arm-unknown-linux-gnueabihf",
             "riscv64gc-unknown-linux-gnu",
             "x86_64-apple-darwin",
             "x86_64-pc-windows-gnu",
             "x86_64-pc-windows-msvc",
             "x86_64-unknown-linux-gnu",
             "x86_64-unknown-linux-musl",
             "x86_64-unknown-freebsd"
           ]
  end

  test "new/1 validates the given nif_versions" do
    opts = [
      otp_app: :rustler_precompiled,
      module: RustlerPrecompilationExample.Native,
      base_url:
        "https://github.com/philss/rustler_precompilation_example/releases/download/v0.2.0",
      version: "0.2.0-dev"
    ]

    assert_raise RuntimeError,
                 "`:nif_versions` is required to be a list of supported nif_versions",
                 fn ->
                   Config.new(opts ++ [nif_versions: "2.16"])
                 end

    assert_raise RuntimeError,
                 "`:nif_versions` is required for `RustlerPrecompiled`",
                 fn ->
                   Config.new(opts ++ [nif_versions: nil])
                 end

    assert_raise RuntimeError,
                 """
                 `:nif_versions` contains nif_versions that are not supported:

                 ["2.nonexistent"]
                 """,
                 fn ->
                   Config.new(
                     opts ++
                       [
                         nif_versions: [
                           "2.14",
                           "2.15",
                           "2.16",
                           "2.nonexistent"
                         ]
                       ]
                   )
                 end
  end

  test "new/1 configures a set of default nif_versions" do
    config =
      Config.new(
        otp_app: :rustler_precompiled,
        module: RustlerPrecompilationExample.Native,
        base_url:
          "https://github.com/philss/rustler_precompilation_example/releases/download/v0.2.0",
        version: "0.2.0-dev"
      )

    assert config.nif_versions == [
             "2.15",
             "2.16"
           ]
  end

  test "new/1 sets a default retry options" do
    config =
      Config.new(
        otp_app: :rustler_precompiled,
        module: RustlerPrecompilationExample.Native,
        base_url:
          "https://github.com/philss/rustler_precompilation_example/releases/download/v0.2.0",
        version: "0.2.0-dev"
      )

    assert config.retry
    assert config.retry_attempts == 3
  end

  test "new/1 validates retry_attempts option" do
    opts = [
      otp_app: :rustler_precompiled,
      module: RustlerPrecompilationExample.Native,
      retry_attempts: 4,
      base_url:
        "https://github.com/philss/rustler_precompilation_example/releases/download/v0.2.0",
      version: "0.2.0-dev"
    ]

    assert Config.new(opts).retry_attempts == 4

    for n <- 1..15 do
      opts = Keyword.update!(opts, :retry_attempts, fn _ -> n end)
      assert Config.new(opts).retry_attempts == n
    end

    opts = Keyword.update!(opts, :retry_attempts, fn _ -> 16 end)
    assert_raise RuntimeError, fn -> Config.new(opts) end

    opts = Keyword.update!(opts, :retry_attempts, fn _ -> -1 end)
    assert_raise RuntimeError, fn -> Config.new(opts) end

    opts = Keyword.update!(opts, :retry_attempts, fn _ -> "invalid" end)
    assert_raise RuntimeError, fn -> Config.new(opts) end

    opts = Keyword.update!(opts, :retry_attempts, fn _ -> nil end)
    assert_raise RuntimeError, fn -> Config.new(opts) end
  end
end
