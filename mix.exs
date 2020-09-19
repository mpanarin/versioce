defmodule Versioce.MixProject do
  use Mix.Project

  def project do
    [
      app: :versioce,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: []
    ]
  end

  defp deps do
    []
  end
end
