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
             "x86_64-unknown-linux-musl"
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
             "2.15"
           ]
  end

  test "new/1 sets a default max_retries option" do
    config =
      Config.new(
        otp_app: :rustler_precompiled,
        module: RustlerPrecompilationExample.Native,
        base_url:
          "https://github.com/philss/rustler_precompilation_example/releases/download/v0.2.0",
        version: "0.2.0-dev"
      )

    assert config.max_retries == 3
  end

  test "new/1 validates max_retries option" do
    opts = [
      otp_app: :rustler_precompiled,
      module: RustlerPrecompilationExample.Native,
      max_retries: 4,
      base_url:
        "https://github.com/philss/rustler_precompilation_example/releases/download/v0.2.0",
      version: "0.2.0-dev"
    ]

    assert Config.new(opts).max_retries == 4

    for n <- 1..15 do
      opts = Keyword.update!(opts, :max_retries, fn _ -> n end)
      assert Config.new(opts).max_retries == n
    end

    opts = Keyword.update!(opts, :max_retries, fn _ -> 16 end)
    assert_raise RuntimeError, fn -> Config.new(opts) end

    opts = Keyword.update!(opts, :max_retries, fn _ -> -1 end)
    assert_raise RuntimeError, fn -> Config.new(opts) end

    opts = Keyword.update!(opts, :max_retries, fn _ -> "invalid" end)
    assert_raise RuntimeError, fn -> Config.new(opts) end

    opts = Keyword.update!(opts, :max_retries, fn _ -> nil end)
    assert_raise RuntimeError, fn -> Config.new(opts) end
  end

  test "new/1 validates variants" do
    variants = %{"x86_64-unknown-linux-gnu" => [old_glibc: fn _config -> true end]}

    opts = [
      otp_app: :rustler_precompiled,
      module: RustlerPrecompilationExample.Native,
      base_url:
        "https://github.com/philss/rustler_precompilation_example/releases/download/v0.2.0",
      variants: variants,
      version: "0.2.0-dev"
    ]

    assert Config.new(opts).variants == variants

    zero_arity_variants = %{"x86_64-unknown-linux-gnu" => [old_glibc: fn -> true end]}
    opts = Keyword.update!(opts, :variants, fn _ -> zero_arity_variants end)

    assert Config.new(opts).variants == zero_arity_variants

    opts = Keyword.update!(opts, :variants, fn _ -> nil end)
    assert Config.new(opts).variants == %{}

    invalid_target_in_variants = %{"x86_64-unknown-lizzard-hurd" => [old_glibc: fn -> true end]}
    opts = Keyword.update!(opts, :variants, fn _ -> invalid_target_in_variants end)

    error_msg =
      ~s|`:variants` contains a target that is not in the list of valid targets: "x86_64-unknown-lizzard-hurd"|

    assert_raise RuntimeError, error_msg, fn -> Config.new(opts) end

    more_than_one_arity_variants = %{
      "x86_64-unknown-linux-gnu" => [old_glibc: fn _config, _foo -> true end]
    }

    opts = Keyword.update!(opts, :variants, fn _ -> more_than_one_arity_variants end)

    error_msg =
      "`:variants` expects a keyword list as values with functions to detect if a given variant is to be activated"

    assert_raise RuntimeError, error_msg, fn -> Config.new(opts) end

    variants_without_keywords = %{"x86_64-unknown-linux-gnu" => [{"old_glibc", fn -> true end}]}
    opts = Keyword.update!(opts, :variants, fn _ -> variants_without_keywords end)

    error_msg =
      ~s|`:variants` expects a keyword list as values, but found a key that is not an atom: "old_glibc"|

    assert_raise RuntimeError, error_msg, fn -> Config.new(opts) end
  end
end
