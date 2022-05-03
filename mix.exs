defmodule BoomSlackNotifier.MixProject do
  use Mix.Project

  @source_url "https://github.com/wyeworks/boom_slack_notifier"

  def project do
    [
      app: :boom_slack_notifier,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [
        plt_add_apps: [:mix],
        plt_core_path: "priv/plts",
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ],
      elixirc_paths: elixirc_paths(Mix.env()),
      description: description(),
      package: package(),
      docs: docs()
    ]
  end

  defp description do
    """
    Provides a custom notifier for the Boom Notifier package.
    It allows sending slack messages whenever an exception is raised in your phoenix app.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md"],
      maintainers: ["Wyeworks"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Docs" => "https://hexdocs.pm/boom_slack_notifier"
      }
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:boom_notifier, "~> 0.8.0"},
      {:httpoison, "~> 1.5"},
      {:jason, "~> 1.2"},

      # Test dependencies
      {:phoenix, "~> 1.4", only: :test},

      # Dev dependencies
      {:dialyxir, "~> 1.1", only: :dev, runtime: false},
      {:ex_doc, "~> 0.23", only: :dev}
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: @source_url,
      extras: [
        "README.md"
      ]
    ]
  end
end
