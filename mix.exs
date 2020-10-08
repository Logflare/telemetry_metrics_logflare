defmodule LogflareTelemetry.MixProject do
  use Mix.Project

  def project do
    [
      app: :logflare_telemetry,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {LogflareTelemetry.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:typed_struct, "~> 0.2.1"},
      {:telemetry, "~> 0.4.0"},
      {:telemetry_poller, "~> 0.5.0"},
      {:telemetry_metrics, "~> 0.6.0", override: true},
      {:cachex, "~> 3.0"},
      {:map_keys, "~> 0.1.0"},

      # HTTP
      {:tesla, "~> 1.0"},
      {:mint, "~> 1.0"},

      # Testing,
      {:postgrex, "~> 0.15", only: :test},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:faker, "~> 0.12", only: :test, runtime: false},
      {:mimic, "~> 1.3", only: :test},

      # Code quality
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:sobelow, ">= 0.0.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.11", only: :test, runtime: false},
      {:logflare_logger_backend, "~> 0.7"}
    ]
  end
end
