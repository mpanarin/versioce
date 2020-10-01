defmodule Mix.Tasks.Bump do
  @shortdoc "Bump the version of your project"
  @moduledoc """
  A task that bumps your projects version.

  > mix bump major|minor|patch [--pre :string] [--build :string] [--no-pre-hooks] [--no-post-hooks]

  ## Examples:

      $> mix bump patch --pre alpha
      Running pre-hooks: []
      Bumping version from 0.0.2:
      "0.0.3-alpha"
      Running post-hooks: []
  """
  use Mix.Task
  alias Versioce.Bumper
  alias Versioce.Config

  @preferred_cli_env :dev

  defp run({:error, error} = res, _) do
    IO.puts("Error: #{error}")

    res
  end

  defp run({:ok, current_version}, params) do
    if "--no-pre-hooks" not in params do
      IO.inspect(Config.pre_hooks, label: "Running pre-hooks")
      Enum.reduce(Config.pre_hooks, params, fn module, params ->
        module.run(params)
      end)
    end

    IO.puts("Bumping version from #{current_version}:")
    new_version = Bumper.bump(params, current_version)
    |> IO.inspect

    if "--no-post-hooks" not in params do
      IO.inspect(Config.post_hooks, label: "Running post-hooks")
      Enum.reduce(Config.post_hooks, new_version, fn module, params ->
        module.run(params)
      end)
    end

    {:ok, new_version}
  end

  @doc false
  @spec run([String.t]) :: {:ok, String.t} | {:error, String.t}
  @impl Mix.Task
  def run(params) do
    run(Bumper.current_version, params)
  end
end
