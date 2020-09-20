defmodule Mix.Tasks.Bump do
  use Mix.Task
  alias Versioce.Bumper

  @shortdoc "Bump the version of your project"
  @moduledoc """
  A task that bumps your projects version.
  """

  @preferred_cli_env :dev

  @pre_hooks Application.compile_env(:versioce, :pre_hooks)
  @post_hooks Application.compile_env(:versioce, :post_hooks)

  defp run({:error, error} = res, _) do
    IO.puts("Error: #{error}")

    res
  end

  defp run({:ok, current_version}, params) do
    IO.inspect(@pre_hooks, label: "Running pre-hooks")
    Enum.reduce(@pre_hooks, params, fn module, params ->
      module.run(params)
    end)

    IO.puts("Bumping version from #{current_version}:")
    new_version = Bumper.bump(params, current_version)
    |> IO.inspect

    IO.inspect(@post_hooks, label: "Running post-hooks")
    Enum.reduce(@post_hooks, new_version, fn module, params ->
      module.run(params)
    end)

    {:ok, new_version}
  end

  @spec run([String.t]) :: {:ok, String.t} | {:error, String.t}
  @impl Mix.Task
  def run(params) do
    run(Bumper.current_version, params)
  end

end
