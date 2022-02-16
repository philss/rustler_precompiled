defmodule RustlerPrecompiled.MixProject do
  use Mix.Project

  def project do
    [
      app: :rustler_precompiled,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      docs: docs(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :crypto, :inets, :public_key]
    ]
  end

  defp docs do
    [
      main: "RustlerPrecompiled",
      extras: ["PRECOMPILATION_GUIDE.md"]
    ]
  end

  defp deps do
    [
      {:castore, "~> 0.1.14"},
      {:ex_doc, "~> 0.27", only: :dev},
      {:bypass, "~> 2.1", only: :test}
    ]
  end
end
