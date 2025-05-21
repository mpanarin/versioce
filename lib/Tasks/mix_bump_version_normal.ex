defmodule Mix.Tasks.Bump.Version.Normal do
  use Mix.Task

  @preferred_cli_env :dev
  @shortdoc "Get current normal version of your project"
  @moduledoc """
  Prints current normal project version.

  ## Examples:

      $> mix bump.version
      "0.1.0-alpha"
      $> mix bump.version.normal
      "0.1.0"
  """

  @doc false
  def run(_) do
    {_, text} = Versioce.Bumper.current_normal_version()

    IO.puts(text)
  end
end
