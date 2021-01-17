defmodule Sternhalma.MixProject do
  use Mix.Project

  @source_url "https://github.com/denvaar/sternhalma"

  def project() do
    [
      app: :sternhalma,
      version: "0.1.1",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      source_url: @source_url,
      description: """
      Provides a set of functions for making a Chinese Checkers game.
      """,
      name: "Sternhalma"
    ]
  end

  defp package() do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application() do
    [
      extra_applications: [:logger]
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
