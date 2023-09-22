defmodule RustlerPrecompiledTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureLog

  @available_targets RustlerPrecompiled.Config.default_targets()
  @available_nif_versions RustlerPrecompiled.Config.available_nif_versions()

  describe "target/1" do
    test "arm 64 bits in an Apple with Darwin-based OS" do
      target_system = %{arch: "arm", vendor: "apple", os: "darwin20.3.0"}

      config = %{
        target_system: target_system,
        nif_version: "2.16",
        os_type: {:unix, :darwin}
      }

      assert {:ok, "nif-2.16-aarch64-apple-darwin"} =
               RustlerPrecompiled.target(config, @available_targets, @available_nif_versions)
    end

    test "x86_64 in an Apple machine with Darwin-based OS" do
      target_system = %{arch: "x86_64", vendor: "apple", os: "darwin20.3.0"}

      config = %{
        target_system: target_system,
        nif_version: "2.15",
        os_type: {:unix, :darwin}
      }

      assert {:ok, "nif-2.15-x86_64-apple-darwin"} =
               RustlerPrecompiled.target(config, @available_targets, @available_nif_versions)
    end

    test "x86_64 in a PC running RedHat Linux" do
      target_system = %{arch: "x86_64", vendor: "redhat", os: "linux", abi: "gnu"}

      config = %{
        target_system: target_system,
        nif_version: "2.14",
        os_type: {:unix, :linux}
      }

      assert {:ok, "nif-2.14-x86_64-unknown-linux-gnu"} =
               RustlerPrecompiled.target(config, @available_targets, @available_nif_versions)
    end

    test "x86_64 in a PC running SUSE Linux" do
      target_system = %{arch: "x86_64", vendor: "suse", os: "linux", abi: "gnu"}

      config = %{
        target_system: target_system,
        nif_version: "2.14",
        os_type: {:unix, :linux}
      }

      assert {:ok, "nif-2.14-x86_64-unknown-linux-gnu"} =
               RustlerPrecompiled.target(config, @available_targets, @available_nif_versions)
    end

    test "x86_64 or amd64 in a PC running Linux" do
      target_system = %{arch: "amd64", vendor: "pc", os: "linux", abi: "gnu"}

      config = %{
        target_system: target_system,
        nif_version: "2.14",
        os_type: {:unix, :linux}
      }

      assert {:ok, "nif-2.14-x86_64-unknown-linux-gnu"} =
               RustlerPrecompiled.target(config, @available_targets, @available_nif_versions)

      config = %{
        config
        | target_system: %{arch: "x86_64", vendor: "unknown", os: "linux", abi: "gnu"}
      }

      assert {:ok, "nif-2.14-x86_64-unknown-linux-gnu"} =
               RustlerPrecompiled.target(config, @available_targets, @available_nif_versions)
    end

    test "arm running a Linux OS" do
      config = %{
        target_system: %{arch: "arm", vendor: "unknown", os: "linux", abi: "gnueabihf"},
        nif_version: "2.16",
        os_type: {:unix, :linux}
      }

      assert {:ok, "nif-2.16-arm-unknown-linux-gnueabihf"} =
               RustlerPrecompiled.target(config, @available_targets, @available_nif_versions)
    end

    test "arm64 running a Linux OS" do
      config = %{
        target_system: %{arch: "aarch64", vendor: "unknown", os: "linux", abi: "gnu"},
        nif_version: "2.16",
        os_type: {:unix, :linux}
      }

      assert {:ok, "nif-2.16-aarch64-unknown-linux-gnu"} =
               RustlerPrecompiled.target(config, @available_targets, @available_nif_versions)
    end

    test "arm64 running in a Darwin-based OS targeting Linux" do
      config = %{
        target_system: %{arch: "aarch64", vendor: "unknown", os: "linux", abi: "gnu"},
        nif_version: "2.16",
        os_type: {:unix, :darwin}
      }

      assert {:ok, "nif-2.16-aarch64-unknown-linux-gnu"} =
               RustlerPrecompiled.target(config, @available_targets, @available_nif_versions)
    end

    test "x86_64 running on Windows with MSVC ABI" do
      config = %{
        target_system: %{},
        word_size: 8,
        nif_version: "2.14",
        os_type: {:win32, :nt}
      }

      assert {:ok, "nif-2.14-x86_64-pc-windows-msvc"} =
               RustlerPrecompiled.target(config, @available_targets, @available_nif_versions)
    end

    test "arm running on windows targeting Linux" do
      config = %{
        target_system: %{arch: "arm", vendor: "unknown", os: "linux", abi: "gnueabihf"},
        word_size: 8,
        nif_version: "2.14",
        os_type: {:win32, :nt}
      }

      assert {:ok, "nif-2.14-arm-unknown-linux-gnueabihf"} =
               RustlerPrecompiled.target(config, @available_targets, @available_nif_versions)
    end

    test "riscv64 running a Linux OS" do
      config = %{
        target_system: %{arch: "riscv64", vendor: "unknown", os: "linux", abi: "gnu"},
        nif_version: "2.16",
        os_type: {:unix, :linux}
      }

      assert {:ok, "nif-2.16-riscv64gc-unknown-linux-gnu"} =
               RustlerPrecompiled.target(
                 config,
                 @available_targets ++ ["riscv64gc-unknown-linux-gnu"],
                 @available_nif_versions
               )
    end

    test "riscv64 running a Linux OS with MUSL" do
      config = %{
        target_system: %{arch: "riscv64", vendor: "unknown", os: "linux", abi: "musl"},
        nif_version: "2.16",
        os_type: {:unix, :linux}
      }

      assert {:ok, "nif-2.16-riscv64gc-unknown-linux-musl"} =
               RustlerPrecompiled.target(
                 config,
                 @available_targets ++ ["riscv64gc-unknown-linux-musl"],
                 @available_nif_versions
               )
    end

    test "amd64 running FreeBSD" do
      target_system = %{arch: "amd64", vendor: "portbld", os: "freebsd13.1"}

      config = %{
        target_system: target_system,
        nif_version: "2.16",
        os_type: {:unix, :freebsd}
      }

      assert {:ok, "nif-2.16-x86_64-unknown-freebsd"} =
               RustlerPrecompiled.target(
                 config,
                 RustlerPrecompiled.Config.available_targets(),
                 @available_nif_versions
               )
    end

    test "without specified available_targets or available_nif_versions" do
      config = %{
        target_system: %{arch: "arm", vendor: "unknown", os: "linux", abi: "gnueabihf"},
        nif_version: "2.16",
        os_type: {:unix, :linux}
      }

      assert {:ok, "nif-2.16-arm-unknown-linux-gnueabihf"} = RustlerPrecompiled.target(config)
    end

    test "target not available" do
      config = %{
        target_system: %{arch: "i686", vendor: "unknown", os: "linux", abi: "gnu"},
        nif_version: "2.14",
        os_type: {:unix, :linux}
      }

      error_message =
        """
        precompiled NIF is not available for this target: \"i686-unknown-linux-gnu\".
        The available targets are:
         - aarch64-apple-darwin
         - aarch64-unknown-linux-gnu
         - aarch64-unknown-linux-musl
         - arm-unknown-linux-gnueabihf
         - riscv64gc-unknown-linux-gnu
         - x86_64-apple-darwin
         - x86_64-pc-windows-gnu
         - x86_64-pc-windows-msvc
         - x86_64-unknown-linux-gnu
         - x86_64-unknown-linux-musl
        """
        |> String.trim()

      assert {:error, ^error_message} = RustlerPrecompiled.target(config, @available_targets)
    end

    test "nif_version not available" do
      config = %{
        target_system: %{arch: "arm", vendor: "unknown", os: "linux", abi: "gnueabihf"},
        nif_version: "2.10",
        os_type: {:unix, :linux}
      }

      error_message =
        "precompiled NIF is not available for this NIF version: \"2.10\".\nThe available NIF versions are:\n - 2.14\n - 2.15\n - 2.16\n - 2.17"

      assert {:error, ^error_message} =
               RustlerPrecompiled.target(config, @available_targets, @available_nif_versions)
    end
  end

  test "find_compatible_nif_version/2" do
    available = ~w(2.14 2.15 2.16)

    assert RustlerPrecompiled.find_compatible_nif_version("2.14", available) == {:ok, "2.14"}
    assert RustlerPrecompiled.find_compatible_nif_version("2.15", available) == {:ok, "2.15"}
    assert RustlerPrecompiled.find_compatible_nif_version("2.16", available) == {:ok, "2.16"}
    assert RustlerPrecompiled.find_compatible_nif_version("2.17", available) == {:ok, "2.16"}
    assert RustlerPrecompiled.find_compatible_nif_version("2.13", available) == :error
    assert RustlerPrecompiled.find_compatible_nif_version("3.0", available) == :error
    assert RustlerPrecompiled.find_compatible_nif_version("1.0", available) == :error

    assert RustlerPrecompiled.find_compatible_nif_version("2.14", ["2.14"]) == {:ok, "2.14"}
    assert RustlerPrecompiled.find_compatible_nif_version("2.17", ["2.14"]) == {:ok, "2.14"}
    assert RustlerPrecompiled.find_compatible_nif_version("2.13", ["2.14"]) == :error
  end

  test "maybe_override_with_env_vars/2" do
    target_system = %{
      arch: "x86_64",
      vendor: "apple",
      os: "darwin20.3.0"
    }

    assert RustlerPrecompiled.maybe_override_with_env_vars(target_system, fn _ -> nil end) ==
             target_system

    env_with_targets = fn
      "TARGET_OS" -> "linux"
      "TARGET_ARCH" -> "aarch64"
      "TARGET_ABI" -> "gnu"
      _ -> nil
    end

    assert RustlerPrecompiled.maybe_override_with_env_vars(target_system, env_with_targets) == %{
             arch: "aarch64",
             vendor: "unknown",
             os: "linux",
             abi: "gnu"
           }

    env_with_targets = fn
      "TARGET_OS" -> "freebsd"
      "TARGET_ARCH" -> "arm"
      "TARGET_ABI" -> "musl"
      "TARGET_VENDOR" -> "ecorp"
    end

    assert RustlerPrecompiled.maybe_override_with_env_vars(target_system, env_with_targets) == %{
             arch: "arm",
             vendor: "ecorp",
             os: "freebsd",
             abi: "musl"
           }
  end

  @tag :tmp_dir
  test "check_integrity_from_map/3", %{tmp_dir: tmp_dir} do
    content = """
    Roses are red
    Violets are blue
    """

    file_path = Path.join(tmp_dir, "poem.txt")
    :ok = File.write(file_path, content)

    # the checksum is calculated with `:crypto.hash(:sha256, content) |> Base.encode16(case: :lower)`
    checksum_map = %{
      "poem.txt" => "sha256:fe16da553f29a704ad4c78624bc9354b8e4df6e4de8edb5b0f8d9f9090501911"
    }

    assert :ok = RustlerPrecompiled.check_integrity_from_map(checksum_map, file_path, MyModule)

    assert {:error,
            "the precompiled NIF file does not exist in the checksum file. Please consider run: `mix rustler_precompiled.download MyModule --only-local` to generate the checksum file."} =
             RustlerPrecompiled.check_integrity_from_map(checksum_map, "idontexist", MyModule)

    not_supported_checksum_map = %{
      "poem.txt" => "md5:fe16da553f29a704ad4c78624bc9354b8e4df6e4de8edb5b0f8d9f9090501911"
    }

    assert {:error,
            "checksum algorithm is not supported: :md5. The supported ones are:\n - sha256"} =
             RustlerPrecompiled.check_integrity_from_map(
               not_supported_checksum_map,
               file_path,
               MyModule
             )

    :ok = File.write(file_path, "let's change the content of the file")

    assert {:error, "the integrity check failed because the checksum of files does not match"} =
             RustlerPrecompiled.check_integrity_from_map(checksum_map, file_path, MyModule)

    wrong_file_path = Path.join(tmp_dir, "i-dont-exist/poem.txt")

    assert {:error, message} =
             RustlerPrecompiled.check_integrity_from_map(checksum_map, wrong_file_path, MyModule)

    assert message =~ "cannot read the file for checksum comparison: "
    assert message =~ wrong_file_path
    assert message =~ "Reason: :enoent"
  end

  describe "download_or_reuse_nif_file/2" do
    setup do
      root_path = File.cwd!()
      nif_fixtures_dir = Path.join(root_path, "test/fixtures")
      checksum_sample_file = Path.join(nif_fixtures_dir, "checksum-sample-file.exs")
      checksum_sample = File.read!(checksum_sample_file)

      {:ok, nif_fixtures_dir: nif_fixtures_dir, checksum_sample: checksum_sample}
    end

    @tag :tmp_dir
    test "a project using precompiled NIFs from cache", %{
      tmp_dir: tmp_dir,
      checksum_sample: checksum_sample,
      nif_fixtures_dir: nif_fixtures_dir
    } do
      in_tmp(tmp_dir, fn ->
        File.write!("checksum-Elixir.RustlerPrecompilationExample.Native.exs", checksum_sample)

        result =
          capture_log(fn ->
            config = %RustlerPrecompiled.Config{
              otp_app: :rustler_precompiled,
              module: RustlerPrecompilationExample.Native,
              base_cache_dir: nif_fixtures_dir,
              base_url:
                "https://github.com/philss/rustler_precompilation_example/releases/download/v0.2.0",
              version: "0.2.0",
              crate: "example",
              targets: @available_targets,
              nif_versions: @available_nif_versions
            }

            {:ok, metadata} = RustlerPrecompiled.build_metadata(config)

            assert {:ok, result} = RustlerPrecompiled.download_or_reuse_nif_file(config, metadata)

            assert result.load?
            assert {:rustler_precompiled, path} = result.load_from

            assert path =~ "priv/native"
            assert path =~ "example-v0.2.0-nif"
          end)

        refute result =~ "Downloading"
        refute result =~ "http://localhost"
        assert result =~ "from cache"
      end)
    end

    @tag :tmp_dir
    test "a project downloading precompiled NIFs", %{
      tmp_dir: tmp_dir,
      checksum_sample: checksum_sample,
      nif_fixtures_dir: nif_fixtures_dir
    } do
      bypass = Bypass.open()

      in_tmp(tmp_dir, fn ->
        File.write!("checksum-Elixir.RustlerPrecompilationExample.Native.exs", checksum_sample)

        Bypass.expect_once(bypass, fn conn ->
          file_name = List.last(conn.path_info)
          file = File.read!(Path.join([nif_fixtures_dir, "precompiled_nifs", file_name]))

          Plug.Conn.resp(conn, 200, file)
        end)

        result =
          capture_log(fn ->
            config = %RustlerPrecompiled.Config{
              otp_app: :rustler_precompiled,
              module: RustlerPrecompilationExample.Native,
              base_cache_dir: tmp_dir,
              base_url: "http://localhost:#{bypass.port}/download",
              version: "0.2.0",
              crate: "example",
              targets: @available_targets,
              nif_versions: @available_nif_versions
            }

            {:ok, metadata} = RustlerPrecompiled.build_metadata(config)

            assert {:ok, result} = RustlerPrecompiled.download_or_reuse_nif_file(config, metadata)

            assert result.load?
            assert {:rustler_precompiled, path} = result.load_from

            assert path =~ "priv/native"
            assert path =~ "example-v0.2.0-nif"
          end)

        assert result =~ "Downloading"
        assert result =~ "http://localhost:#{bypass.port}/download"
        assert result =~ "NIF cached at"
      end)
    end

    @tag :tmp_dir
    test "a project downloading precompiled NIFs with retry", %{
      tmp_dir: tmp_dir,
      checksum_sample: checksum_sample,
      nif_fixtures_dir: nif_fixtures_dir
    } do
      bypass = Bypass.open()
      {:ok, agent} = Agent.start_link(fn -> 1 end)

      in_tmp(tmp_dir, fn ->
        File.write!("checksum-Elixir.RustlerPrecompilationExample.Native.exs", checksum_sample)

        Bypass.expect(bypass, fn conn ->
          current_attempt = Agent.get(agent, & &1)

          if current_attempt == 2 do
            file_name = List.last(conn.path_info)
            file = File.read!(Path.join([nif_fixtures_dir, "precompiled_nifs", file_name]))

            Plug.Conn.resp(conn, 200, file)
          else
            :ok = Agent.update(agent, &(&1 + 1))

            Plug.Conn.resp(conn, 500, "Server is down")
          end
        end)

        result =
          capture_log(fn ->
            config = %RustlerPrecompiled.Config{
              otp_app: :rustler_precompiled,
              module: RustlerPrecompilationExample.Native,
              base_cache_dir: tmp_dir,
              base_url: "http://localhost:#{bypass.port}/download",
              version: "0.2.0",
              crate: "example",
              targets: @available_targets,
              nif_versions: @available_nif_versions
            }

            {:ok, metadata} = RustlerPrecompiled.build_metadata(config)

            assert {:ok, result} = RustlerPrecompiled.download_or_reuse_nif_file(config, metadata)

            assert result.load?
            assert {:rustler_precompiled, path} = result.load_from

            assert path =~ "priv/native"
            assert path =~ "example-v0.2.0-nif"
          end)

        assert Agent.get(agent, & &1) == 2

        assert result =~ "Attempt 1 failed"
        assert result =~ "Internal Server Error"

        assert result =~ "Downloading"
        assert result =~ "http://localhost:#{bypass.port}/download"
        assert result =~ "NIF cached at"
      end)
    end

    @tag :tmp_dir
    test "a project downloading precompiled NIFs with error and retry disabled", %{
      tmp_dir: tmp_dir,
      checksum_sample: checksum_sample
    } do
      bypass = Bypass.open()
      {:ok, agent} = Agent.start_link(fn -> 0 end)

      in_tmp(tmp_dir, fn ->
        File.write!("checksum-Elixir.RustlerPrecompilationExample.Native.exs", checksum_sample)

        Bypass.expect(bypass, fn conn ->
          :ok = Agent.update(agent, &(&1 + 1))

          Plug.Conn.resp(conn, 500, "Server is down")
        end)

        capture_log(fn ->
          config = %RustlerPrecompiled.Config{
            otp_app: :rustler_precompiled,
            module: RustlerPrecompilationExample.Native,
            base_cache_dir: tmp_dir,
            base_url: "http://localhost:#{bypass.port}/download",
            version: "0.2.0",
            crate: "example",
            max_retries: 0,
            targets: @available_targets,
            nif_versions: @available_nif_versions
          }

          {:ok, metadata} = RustlerPrecompiled.build_metadata(config)

          assert {:error, error} = RustlerPrecompiled.download_or_reuse_nif_file(config, metadata)

          assert error =~ "Server is down"
        end)

        assert Agent.get(agent, & &1) == 1
      end)
    end

    @tag :tmp_dir
    test "a project downloading precompiled NIFs without the checksum file", %{
      tmp_dir: tmp_dir,
      nif_fixtures_dir: nif_fixtures_dir
    } do
      bypass = Bypass.open()

      in_tmp(tmp_dir, fn ->
        Bypass.expect_once(bypass, fn conn ->
          file_name = List.last(conn.path_info)
          file = File.read!(Path.join([nif_fixtures_dir, "precompiled_nifs", file_name]))

          Plug.Conn.resp(conn, 200, file)
        end)

        capture_log(fn ->
          config = %RustlerPrecompiled.Config{
            otp_app: :rustler_precompiled,
            module: RustlerPrecompilationExample.Native,
            base_cache_dir: tmp_dir,
            base_url: "http://localhost:#{bypass.port}/download",
            version: "0.2.0",
            crate: "example",
            targets: @available_targets,
            nif_versions: @available_nif_versions
          }

          {:ok, metadata} = RustlerPrecompiled.build_metadata(config)

          assert {:error, error} = RustlerPrecompiled.download_or_reuse_nif_file(config, metadata)

          assert error =~
                   "the precompiled NIF file does not exist in the checksum file. " <>
                     "Please consider run: `mix rustler_precompiled.download RustlerPrecompilationExample.Native --only-local` " <>
                     "to generate the checksum file."
        end)
      end)
    end
  end

  describe "build_metadata/1" do
    test "builds a valid metadata" do
      config = %RustlerPrecompiled.Config{
        otp_app: :rustler_precompiled,
        module: RustlerPrecompilationExample.Native,
        base_url:
          "https://github.com/philss/rustler_precompilation_example/releases/download/v0.2.0",
        version: "0.2.0",
        crate: "example",
        targets: @available_targets,
        variants: %{},
        nif_versions: @available_nif_versions
      }

      assert {:ok, metadata} = RustlerPrecompiled.build_metadata(config)

      assert metadata.otp_app == :rustler_precompiled
      assert metadata.basename == "example"
      assert metadata.crate == "example"

      assert String.ends_with?(metadata.cached_tar_gz, "tar.gz")
      assert [_ | _] = metadata.targets
      assert metadata.nif_versions == @available_nif_versions
      assert metadata.version == "0.2.0"
      assert metadata.base_url == config.base_url
      assert metadata.variants == %{}
    end

    test "returns error when current target is not available" do
      config = %RustlerPrecompiled.Config{
        otp_app: :rustler_precompiled,
        module: RustlerPrecompilationExample.Native,
        base_url:
          "https://github.com/philss/rustler_precompilation_example/releases/download/v0.2.0",
        version: "0.2.0",
        crate: "example",
        targets: ["hexagon-unknown-linux-musl"],
        nif_versions: @available_nif_versions
      }

      assert {:error, error} = RustlerPrecompiled.build_metadata(config)
      assert error =~ "precompiled NIF is not available for this target: "
      assert error =~ ".\nThe available targets are:\n - hexagon-unknown-linux-musl"
    end

    test "returns a base metadata when target is not available but force build is enabled" do
      config = %RustlerPrecompiled.Config{
        otp_app: :rustler_precompiled,
        module: RustlerPrecompilationExample.Native,
        base_url:
          "https://github.com/philss/rustler_precompilation_example/releases/download/v0.2.0",
        version: "0.2.0",
        crate: "example",
        targets: ["hexagon-unknown-linux-musl"],
        nif_versions: @available_nif_versions,
        force_build?: true
      }

      assert {:ok, base_metadata} = RustlerPrecompiled.build_metadata(config)

      assert base_metadata[:otp_app] == :rustler_precompiled
      assert base_metadata[:crate] == "example"
      assert base_metadata[:targets] == ["hexagon-unknown-linux-musl"]
      assert base_metadata[:nif_versions] == @available_nif_versions
      assert base_metadata[:version] == "0.2.0"
      assert base_metadata[:base_url] == config.base_url
    end

    test "returns error when current nif_version is not available" do
      config = %RustlerPrecompiled.Config{
        otp_app: :rustler_precompiled,
        module: RustlerPrecompilationExample.Native,
        base_url:
          "https://github.com/philss/rustler_precompilation_example/releases/download/v0.2.0",
        version: "0.2.0",
        crate: "example",
        targets: @available_targets,
        nif_versions: ["4.2"]
      }

      assert {:error, error} = RustlerPrecompiled.build_metadata(config)
      assert error =~ "precompiled NIF is not available for this NIF version: "
      assert error =~ ".\nThe available NIF versions are:\n - 4.2"
    end

    test "returns a base metadata when nif_version is not available but force build is enabled" do
      config = %RustlerPrecompiled.Config{
        otp_app: :rustler_precompiled,
        module: RustlerPrecompilationExample.Native,
        base_url:
          "https://github.com/philss/rustler_precompilation_example/releases/download/v0.2.0",
        version: "0.2.0",
        crate: "example",
        targets: @available_targets,
        nif_versions: ["4.2"],
        force_build?: true
      }

      assert {:ok, base_metadata} = RustlerPrecompiled.build_metadata(config)

      assert base_metadata[:otp_app] == :rustler_precompiled
      assert base_metadata[:crate] == "example"
      assert base_metadata[:targets] == @available_targets
      assert base_metadata[:nif_versions] == ["4.2"]
      assert base_metadata[:version] == "0.2.0"
      assert base_metadata[:base_url] == config.base_url
    end

    test "builds a valid metadata with a restrict NIF versions list" do
      config = %RustlerPrecompiled.Config{
        otp_app: :rustler_precompiled,
        module: RustlerPrecompilationExample.Native,
        base_url:
          "https://github.com/philss/rustler_precompilation_example/releases/download/v0.2.0",
        version: "0.2.0",
        crate: "example",
        targets: @available_targets,
        nif_versions: ["2.15"]
      }

      assert {:ok, metadata} = RustlerPrecompiled.build_metadata(config)

      assert metadata.nif_versions == ["2.15"]
    end

    test "builds a valid metadata with specified variants" do
      config = %RustlerPrecompiled.Config{
        otp_app: :rustler_precompiled,
        module: RustlerPrecompilationExample.Native,
        base_url:
          "https://github.com/philss/rustler_precompilation_example/releases/download/v0.2.0",
        version: "0.2.0",
        crate: "example",
        targets: @available_targets,
        variants: %{
          "x86_64-unknown-linux-gnu" => [
            old_glibc: fn _config -> true end,
            legacy_cpus: fn _config -> true end
          ]
        },
        nif_versions: @available_nif_versions
      }

      assert {:ok, metadata} = RustlerPrecompiled.build_metadata(config)

      assert metadata.variants == %{"x86_64-unknown-linux-gnu" => [:old_glibc, :legacy_cpus]}

      # We need this guard because not every one is running the tests in the same OS/Arch.
      if metadata.lib_name =~ "x86_64-unknown-linux-gnu" do
        assert String.ends_with?(metadata.lib_name, "--old_glibc")
        assert String.ends_with?(metadata.file_name, "--old_glibc.so")
      end
    end

    test "builds a valid metadata saving the current variant as legacy CPU" do
      config = %RustlerPrecompiled.Config{
        otp_app: :rustler_precompiled,
        module: RustlerPrecompilationExample.Native,
        base_url:
          "https://github.com/philss/rustler_precompilation_example/releases/download/v0.2.0",
        version: "0.2.0",
        crate: "example",
        targets: @available_targets,
        variants: %{
          "x86_64-unknown-linux-gnu" => [
            old_glibc: fn _config -> false end,
            legacy_cpus: fn _config -> true end
          ]
        },
        nif_versions: @available_nif_versions
      }

      assert {:ok, metadata} = RustlerPrecompiled.build_metadata(config)

      assert metadata.variants == %{"x86_64-unknown-linux-gnu" => [:old_glibc, :legacy_cpus]}

      if metadata.lib_name =~ "x86_64-unknown-linux-gnu" do
        assert String.ends_with?(metadata.lib_name, "--legacy_cpus")
        assert String.ends_with?(metadata.file_name, "--legacy_cpus.so")
      end
    end
  end

  describe "nif_urls_from_metadata/1" do
    test "builds a list of tar gz urls" do
      base_url =
        "https://github.com/philss/rustler_precompilation_example/releases/download/v0.2.0"

      config =
        RustlerPrecompiled.Config.new(
          otp_app: :rustler_precompiled,
          module: RustlerPrecompilationExample.Native,
          base_url: base_url,
          version: "0.2.0",
          crate: "example",
          force_build: false,
          targets: @available_targets,
          nif_versions: @available_nif_versions
        )

      {:ok, metadata} = RustlerPrecompiled.build_metadata(config)

      assert {:ok, nif_urls} = RustlerPrecompiled.nif_urls_from_metadata(metadata)

      assert length(nif_urls) == length(@available_targets) * length(@available_nif_versions)

      for nif_url <- nif_urls do
        assert String.starts_with?(nif_url, base_url)
        assert String.ends_with?(nif_url, ".tar.gz")
      end
    end

    test "builds a list of tar gz urls and its variants" do
      base_url =
        "https://github.com/philss/rustler_precompilation_example/releases/download/v0.2.0"

      config =
        RustlerPrecompiled.Config.new(
          otp_app: :rustler_precompiled,
          module: RustlerPrecompilationExample.Native,
          base_url: base_url,
          version: "0.2.0",
          crate: "example",
          force_build: false,
          targets: @available_targets,
          variants: %{
            "x86_64-unknown-linux-gnu" => [
              old_glibc: fn -> false end,
              legacy_cpus: fn _config -> true end
            ]
          },
          nif_versions: @available_nif_versions
        )

      {:ok, metadata} = RustlerPrecompiled.build_metadata(config)

      assert {:ok, nif_urls} = RustlerPrecompiled.nif_urls_from_metadata(metadata)

      # NIF versions multiplied by 2 new variants.
      variants_count = 8

      assert length(nif_urls) ==
               length(@available_targets) * length(@available_nif_versions) + variants_count

      for nif_url <- nif_urls do
        assert String.starts_with?(nif_url, base_url)
        assert String.ends_with?(nif_url, ".tar.gz")
      end

      with_variants = Enum.filter(nif_urls, &(&1 =~ "--"))
      assert length(with_variants) == variants_count

      for url <- with_variants do
        [_rest, variant] = String.split(url, "--", parts: 2)
        [variant, _rest] = String.split(variant, ".", parts: 2)

        assert variant in ["old_glibc", "legacy_cpus"]
      end
    end

    test "does not build list of tar gz urls due to missing metadata field" do
      base_url =
        "https://github.com/philss/rustler_precompilation_example/releases/download/v0.2.0"

      config =
        RustlerPrecompiled.Config.new(
          otp_app: :rustler_precompiled,
          module: RustlerPrecompilationExample.Native,
          base_url: base_url,
          version: "0.2.0",
          crate: "example",
          force_build: false,
          targets: @available_targets,
          nif_versions: @available_nif_versions
        )

      {:ok, metadata} = RustlerPrecompiled.build_metadata(config)
      metadata = Map.drop(metadata, [:version])

      assert {:error, ^metadata} = RustlerPrecompiled.nif_urls_from_metadata(metadata)
    end
  end

  def in_tmp(tmp_path, function) do
    path = Path.join([tmp_path, random_string(10)])

    try do
      File.rm_rf(path)
      File.mkdir_p!(path)
      File.cd!(path, function)
    after
      File.rm_rf(path)
      :ok
    end
  end

  defp random_string(len) do
    len
    |> :crypto.strong_rand_bytes()
    |> Base.encode64()
    |> binary_part(0, len)
  end
end
