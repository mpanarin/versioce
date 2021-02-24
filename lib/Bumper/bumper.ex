defmodule Versioce.Bumper do
  @moduledoc """
  Module responsible for the bumping itself.

  If you are interested in the process of writing and updating files
  check `Versioce.Bumper.Files` module.
  """

  @doc """
  Get current project version.

  ## Example

      iex> Versioce.Bumper.current_version
      {:ok, "0.1.0"}
  """
  @spec current_version() :: {:ok, String.t} | {:error, String.t}
  def current_version do
    case Mix.Project.get() do
      nil -> {:error, "No project configured"}
      _ -> {:ok, Mix.Project.config()[:version]}
    end
  end

  defp add_build_pre(version, options) do
    build =
      case Keyword.get(options, :build) do
        nil -> nil
        build -> [build]
      end

    pre =
      case Keyword.get(options, :pre) do
        nil -> []
        pre -> [pre]
      end

    Map.merge(version, %{
      build: build,
      pre: pre
    })
  end

  @doc """
  Bumps versions in all the files specified in config + mix.exs

  ## Example

      iex> Versioce.Bumper.bump({[], ["minor"]}, "0.0.1")
      "0.1.0"
  """
  @spec bump({OptionParser.parsed, OptionParser.argv}, String.t) :: String.t
  def bump({[], []}, from) do
    IO.puts("Nothing to do")
    from
  end

  def bump({options, ["patch"]}, from) do
    from_v = Version.parse!(from)

    new_version =
      Map.merge(from_v, %{
        patch: from_v.patch + 1
      })
      |> add_build_pre(options)
      |> to_string

    Version.parse!(new_version)

    Versioce.Bumper.Files.update_version_files(from, new_version)
    new_version
  end

  def bump({options, ["minor"]}, from) do
    from_v = Version.parse!(from)

    new_version =
      Map.merge(from_v, %{
        minor: from_v.minor + 1,
        patch: 0
      })
      |> add_build_pre(options)
      |> to_string

    Version.parse!(new_version)

    Versioce.Bumper.Files.update_version_files(from, new_version)
    new_version
  end

  def bump({options, ["major"]}, from) do
    from_v = Version.parse!(from)

    new_version =
      Map.merge(from_v, %{
        major: from_v.major + 1,
        minor: 0,
        patch: 0
      })
      |> add_build_pre(options)
      |> to_string

    Version.parse!(new_version)

    Versioce.Bumper.Files.update_version_files(from, new_version)
    new_version
  end

  def bump({_, [version]}, from) do
    new_version = Version.parse!(version) |> to_string

    Versioce.Bumper.Files.update_version_files(from, new_version)
    new_version
  end

  def bump({options, []}, from) do
    from_v = Version.parse!(from)

    new_version =
      from_v
      |> add_build_pre(options)
      |> to_string

    Versioce.Bumper.Files.update_version_files(from, new_version)
    new_version
  end
end
