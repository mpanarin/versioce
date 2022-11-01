defmodule Mix.Tasks.Changelog do
  @shortdoc "Generate changelog"
  @moduledoc """
  Generates a changelog for your project.
  """

  use Mix.Task
  import Versioce.OK, only: :macros
  alias Versioce.Config.Changelog, as: ChangelogConf

  @doc false
  @impl Mix.Task
  def run(_) do
    Mix.Task.run("compile")

    ChangelogConf.datagrabber().get_data()
    ~>> ChangelogConf.formatter().format()
    ~>> write_file()
    |> case do
      :ok ->
        nil

      error ->
        IO.inspect(error)
        exit({:shutdown, 1})
    end
  end

  @spec write_file(String.t()) :: :ok | {:error, any}
  defp write_file(data) do
    ChangelogConf.changelog_file()
    |> File.write(data, [:write])
  end
end
