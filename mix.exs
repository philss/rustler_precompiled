defmodule RustlerPrecompiled.MixProject do
  use Mix.Project

  def project do
    [
      app: :rustler_precompiled,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :crypto, :inets, :public_key]
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
