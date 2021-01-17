defmodule Sternhalma.MixProject do
  use Mix.Project

  def project() do
    [
      app: :sternhalma,
      version: "0.1.1",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      source_url: "https://github.com/denvaar/sternhalma"
    ]
  end

  defp package() do
    [
      name: "Sternhalma",
      description: """
      Provides a set of functions for making a Chinese Checkers game.
      """,
      licenses: ["mit"],
      links: %{"GitHub" => "https://github.com/denvaar/sternhalma"}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application() do
    [
      extra_applications: [:logger],
      mod: {Sternhalma.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps() do
    [
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false}
    ]
  end
end
