defmodule Mix.Tasks.Bump.Version do
  use Mix.Task

  @preferred_cli_env :dev
  @shortdoc "Get current version of your project"

  def run(_) do
    {_, text} = Versioce.Bumper.current_version

    IO.puts(text)
  end
end
