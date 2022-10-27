defmodule Versioce.MixProject do
  use Mix.Project

  @source_url "https://github.com/mpanarin/versioce"
  @version "1.1.2"

  def project do
    [
      app: :versioce,
      version: @version,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      # Docs
      name: "Versioce",
      source_url: @source_url,
      docs: docs(),
      # dialyzer
      dialyzer: dialyzer(),
      # coverage
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.json": :test
      ]
    ]
  end

  def application do
    [
      extra_applications: []
    ]
  end

  def description do
    """
    Versioce provides a mix task for version bumping of your project.
    """
  end

  def package do
    [
      name: :versioce,
      maintainers: ["Mykhailo Panarin"],
      licenses: ["GPL-3.0-or-later"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.22", only: [:release, :dev]},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:excoveralls, "~> 0.15", only: :test},
      {:git_cli, "~> 0.3.0", optional: true}
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      extras: [
        "README.md",
        "docs/available_hooks.md",
        "docs/migrations.md"
      ]
    ]
  end

  defp dialyzer do
    [
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
      plt_add_apps: [:mix, :git_cli]
    ]
  end
end
