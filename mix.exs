defmodule Pagination.MixProject do
  use Mix.Project

  def project do
    [
      app: :phoenix_pagination,
      version: "0.7.0",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [
        summary: [
          threshold: 98
        ]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, ">= 3.0.0", optional: true},
      {:phoenix_html, ">= 2.0.0", optional: true},
      {:ecto_sql, ">= 3.0.0", only: :test},
      {:postgrex, "~> 0.15.0", only: :test},
      {:credo, "1.6.7", only: [:dev, :test], runtime: false},
    ]
  end

  defp aliases do
    [
      test: ["ecto.drop", "ecto.create", "ecto.migrate", "test"]
    ]
  end
end
