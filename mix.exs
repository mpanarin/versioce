defmodule Versioce.MixProject do
  use Mix.Project

  def project do
    [
      app: :versioce,
      version: "0.0.2",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: [{:ex_doc, "~> 0.21", only: [:release, :dev]}],
      description: description(),
      package: package(),
      # Docs
      name: "Versioce",
      source_url: "https://github.com/mpanarin/versioce",
      docs: [
        extras: ["README.md"]
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
      links: %{"GitHub" => "https://github.com/mpanarin/versioce"}
    ]
  end
end
