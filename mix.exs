defmodule Filix.MixProject do
  use Mix.Project

  def project do
    [
      app: :filix,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Filix.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:uuid, "~> 1.1"},
      {:ecto, "~> 3.0.0"},
      {:typed_struct, "~> 0.1.4"},
    ]
  end
end
