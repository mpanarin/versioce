defmodule Versioce.PostHooks.Changelog do
  @moduledoc """
  Generates a Changelog in your repository with `Versioce.Config.Changelog.changelog_file/0` filepath.

  It recommended to use this hook before `Versioce.PostHooks.Git.Release` either
  with `Versioce.Config.Git.dirty_add/0` enabled or with changelog file added to
  `Versioce.Config.Git.additional_files/0`
  """
  use Versioce.PostHook
  import Versioce.OK, only: :macros
  alias Versioce.Config.Changelog, as: ChangelogConf

  @impl Versioce.PostHook
  def run(version) do
    ChangelogConf.datagrabber().get_versions(version)
    ~>> ChangelogConf.formatter().format()
    ~>> write_file()
    |> case do
      :ok -> {:ok, version}
      error -> error
    end
  end

  @spec write_file(String.t()) :: :ok | {:error, any}
  defp write_file(data) do
    ChangelogConf.changelog_file()
    |> File.write(data, [:write])
  end
end
