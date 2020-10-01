defmodule Versioce.Bumper.Files do
  @moduledoc """
  Module that is responsible for updating files in the project.
  """

  alias Versioce.Config

  @doc """
  Updates version in files from config from `from` version to `to` version.

  By default only updates first instance of version found.
  If you want to update version in the whole file set `:global` key
  in the config.

      config :versioce,
        global: true
  """
  @spec update_version_files(String.t(), String.t()) :: :ok | Exception
  def update_version_files(from, to) do
    ["mix.exs" | Config.files]
    |> Enum.each(&update_version_file(&1, from, to))
  end

  defp update_version_file(file, from, to) do
    data =
      File.read!(file)
      |> String.replace(from, to, global: Config.global)

    File.write!(file, data)
  end
end
