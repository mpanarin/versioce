defmodule Mix.Tasks.Bump.Version do
  use Mix.Task

  @preferred_cli_env :dev
  @shortdoc "Get current version of your project"
  @moduledoc """
  Prints current project version.

  ## Examples:

      $> mix bump.version
      "0.1.0"
  """

  @doc false
  def run(_) do
    {_, text} = Versioce.Bumper.current_version

    IO.puts(text)
  end
end
