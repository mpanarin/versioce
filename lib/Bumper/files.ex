defmodule Versioce.Bumper.Files do
  @files Application.compile_env!(:versioce, :files)
  @global Application.compile_env!(:versioce, :global)

  @doc """
  Updates version in files from config from `from` version to `to` version.

  By default only updates first instance of version found.
  If you want to update version in the whole file set :global key
  in the config.

  ```elixir
  config :versioce,
    global: true
  ```
  """
  @spec update_version_files(String.t(), String.t()) :: :ok | Exception
  def update_version_files(from, to) do
    ["mix.exs" | @files]
    |> Enum.each(&update_version_file(&1, from, to))
  end

  defp update_version_file(file, from, to) do
    data =
      File.read!(file)
      |> String.replace(from, to, global: @global)

    File.write!(file, data)
  end
end
