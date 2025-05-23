defmodule Mix.Tasks.Bump do
  @shortdoc "Bump the version of your project"
  @moduledoc """
  A task that bumps your projects version.

  > mix bump major|minor|patch|calver [--pre :string] [--build :string] [--no-pre-hooks] [--no-post-hooks]

  major|minor|patch - bumps corresponding part of the project version
  calver - bumps to current calver version

  CalVer does not support --pre and --build. Both will be ignored

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
  @options [pre: :string, build: :string, no_pre_hooks: :boolean, no_post_hooks: :boolean]

  defp run_pre_hooks({options, params}) do
    case Keyword.fetch(options, :no_pre_hooks) do
      {:ok, true} ->
        {:ok, "No hooks to run"}

      _ ->
        hooks =
          Config.pre_hooks()
          |> IO.inspect(label: "Running pre-hooks")

        Versioce.Hooks.run(params, hooks)
    end
  end

  defp run_post_hooks({{options, _}, params}) do
    case Keyword.fetch(options, :no_post_hooks) do
      {:ok, true} ->
        {:ok, "No hooks to run"}

      _ ->
        hooks =
          Config.post_hooks()
          |> IO.inspect(label: "Running post-hooks")

        Versioce.Hooks.run(params, hooks)
    end
  end

  defp bump(current_version, new_version) do
    IO.puts("Bumping version from #{current_version}:")

    Bumper.bump(current_version, new_version) |> IO.inspect()

    {:ok, new_version}
  end

  @doc false
  @spec run(
          {OptionParser.parsed(), OptionParser.argv()},
          {:ok, String.t()} | {:error, String.t()}
        ) :: {:ok, String.t()} | {:error, String.t()}
  def run(_, {:error, error} = res) do
    IO.puts("Error: #{error}")

    res
  end

  def run(options, {:ok, current_version}) do
    new_version = Bumper.get_new_version(options, current_version)

      if new_version === current_version do
        IO.puts("Bumping to the same version, nothing to do")
      else
        with {:ok, _} <- run_pre_hooks(options),
             {:ok, new_version} <- bump(current_version, new_version),
             {:ok, _} <- run_post_hooks({options, new_version}) do
          {:ok, new_version}
        else
          {:error, reason} -> IO.puts(reason)
        end
    end
  end

  @doc false
  @spec parse([String.t()]) :: {OptionParser.parsed(), OptionParser.argv()}
  def parse(options) do
    OptionParser.parse!(options, strict: @options)
  end

  @doc false
  @spec run([String.t()]) :: {:ok, String.t()} | {:error, String.t()}
  @impl Mix.Task
  def run(options) do
    Mix.Task.run("compile")

    options
    |> parse()
    |> run(Bumper.current_version())
  end
end
