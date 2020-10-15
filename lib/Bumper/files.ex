defmodule Versioce.Bumper.Files do
  alias Versioce.Bumper.FilesFake
  alias Versioce.Bumper.FilesImplementation

  defdelegate update_version_files(from, to), to: if Mix.env == :test, do: FilesFake, else: FilesImplementation
end

defmodule Versioce.Bumper.FilesFake do
  @moduledoc false
  def update_version_files(_from, _to), do: :ok
end

defmodule Versioce.Bumper.FilesImplementation do
  @moduledoc """
  Module that is responsible for updating files in the project.
  """

  alias Versioce.Config

  # coveralls-ignore-start
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
  # coveralls-ignore-stop
end
