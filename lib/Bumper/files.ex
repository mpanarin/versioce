defmodule Versioce.Bumper.Files do

  @files Application.compile_env!(:versioce, :files)
  @global Application.compile_env!(:versioce, :global)

  def update_version_files(from, to) do
    ["mix.exs" | @files]
    |> Enum.each(&(update_version_file(&1, from, to)))
  end

  defp update_version_file(file, from, to) do
    data = File.read!(file)
    |> String.replace(from, to, global: @global)

    File.write!(file, data)
  end
end
