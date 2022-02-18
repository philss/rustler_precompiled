defmodule RustlerPrecompiled.ConfigTest do
  use ExUnit.Case, async: true

  alias RustlerPrecompiled.Config

  test "new/0 sets `force_build?` to true when pre-release version is used" do
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

  test "new/0 sets `force_build?` when configured" do
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

  test "new/0 requireds `force_build` option when is not a pre-release" do
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
end
