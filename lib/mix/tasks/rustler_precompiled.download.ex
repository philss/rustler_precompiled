defmodule Mix.Tasks.RustlerPrecompiled.Download do
  @shortdoc "Download precompiled NIFs and build the checksums"

  @moduledoc """
  A task responsible for downloading the precompiled NIFs for a given module.

  This task must only be used by package creators who want to ship the
  precompiled NIFs. The goal is to download the precompiled packages and
  generate a checksum to check-in alongside the project in the the Hex repository.
  This is done by passing the `--all` flag.

  You can also use the `--only-local` flag to download only the precompiled
  package for use during development.

  You can use the `--ignore-unavailable` flag to ignore any NIFs that are not available.
  This is useful when you are developing a new NIF that does not support all platforms.

  This task also accept the `--print` flag to print the checksums.

  Since v0.7.2 we start the app invoking this mix task by default. To avoid that, use
  the `--no-start` flag.

  If the app is started, we are going to check for the compiled module with that name.
  In case the `--no-start` flag is used, we are going to search for a ".beam" file for
  that module, and in case it's not found, we are going to print a message. This is useful
  to avoid typos.
  """

  use Mix.Task

  @switches [
    all: :boolean,
    only_local: :boolean,
    print: :boolean,
    no_start: :boolean,
    ignore_unavailable: :boolean
  ]

  @impl true
  def run([module_name | flags]) do
    module = String.to_atom("Elixir.#{module_name}")

    {options, _args, _invalid} = OptionParser.parse(flags, strict: @switches)

    if options[:no_start] do
      if Path.wildcard("_build/{dev,prod}/lib/**/ebin/Elixir.#{module_name}.beam") == [] do
        IO.puts(
          "Could not find a compiled module with that name. Make sure the project is compiled and the module name is correct."
        )
      end
    else
      Mix.Task.run("app.start", [])

      case Code.ensure_compiled(module) do
        {:module, _module} ->
          :ok

        {:error, error} ->
          IO.puts(
            "Could not ensure that module is compiled. Be sure that the name is correct. Reason: #{inspect(error)}"
          )
      end
    end

    urls =
      cond do
        Keyword.get(options, :all) ->
          RustlerPrecompiled.available_nif_urls(module)

        Keyword.get(options, :only_local) ->
          RustlerPrecompiled.current_target_nif_urls(module)

        true ->
          raise "you need to specify either \"--all\" or \"--only-local\" flags"
      end

    result = RustlerPrecompiled.download_nif_artifacts_with_checksums!(urls, options)

    if Keyword.get(options, :print) do
      result
      |> Enum.map(fn map ->
        {Path.basename(Map.fetch!(map, :path)), Map.fetch!(map, :checksum)}
      end)
      |> Enum.sort()
      |> Enum.map_join("\n", fn {file, checksum} -> "#{checksum}  #{file}" end)
      |> IO.puts()
    end

    RustlerPrecompiled.write_checksum!(module, result)
  end

  @impl true
  def run([]) do
    raise "the module name and a flag is expected. Use \"--all\" or \"--only-local\" flags"
  end
end
