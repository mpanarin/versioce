defmodule Versioce.MixProject do
  use Mix.Project

  @source_url "https://github.com/mpanarin/versioce"
  @version "0.1.1"

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
      docs: docs()
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
      {:ex_doc, "~> 0.22", only: [:release, :dev]}
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      extras: ["README.md"]
    ]
  end
end
