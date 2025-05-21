defmodule Versioce.Bumper do
  @moduledoc """
  Module responsible for the bumping itself.

  If you are interested in the process of writing and updating files
  check `Versioce.Bumper.Files` module.
  """

  alias Versioce.Bumper.CalverFormattingParser
  alias Versioce.Bumper.Files
  alias Versioce.Config

  @doc """
  Get current project version.

  ## Example

      iex> Versioce.Bumper.current_version
      {:ok, "0.1.0"}
  """
  @spec current_version() :: {:ok, String.t()} | {:error, String.t()}
  def current_version do
    case Mix.Project.get() do
      nil -> {:error, "No project configured"}
      _ -> {:ok, Mix.Project.config()[:version]}
    end
  end

  @doc """
  Get current normal project version.

  ## Example

      iex> Versioce.Bumper.current_normal_version
      {:ok, "0.1.0"}
  """
  @spec current_normal_version() :: {:ok, String.t()} | {:error, String.t()}
  def current_normal_version do
    case current_version() do
      {:error, _} = error -> error
      {:ok, version} ->
        version
        |> Version.parse!()
        |> Map.merge(%{pre: [], build: nil})
        |> to_string()
        |> then(fn value -> {:ok, value} end)
    end
  end

  @doc """
  Bumps versions in all the files specified in config.

  ## Example

      iex> Versioce.Bumper.bump("0.0.1", "0.1.0")
      "0.1.0"
  """
  @spec bump(from :: String.t(), to :: String.t()) :: String.t()
  def bump(from, to) do
    Files.update_version_files(from, to)
    to
  end

  @doc """
  Get next project version based on options passed.

  ## Example

      iex> iex> Versioce.Bumper.get_new_version({[], ["minor"]}, "0.0.1")
      "0.1.0"
  """
  @spec get_new_version({OptionParser.parsed(), OptionParser.argv()}, String.t()) :: String.t()
  def get_new_version({[], []}, from) do
    IO.puts("Nothing to do")
    from
  end

  def get_new_version({options, ["patch"]}, from) do
    from_v = Version.parse!(from)

    new_version =
      Map.merge(from_v, %{
        patch: from_v.patch + 1
      })
      |> add_build_pre(options)
      |> to_string

    Version.parse!(new_version)
    new_version
  end

  def get_new_version({options, ["minor"]}, from) do
    from_v = Version.parse!(from)

    new_version =
      Map.merge(from_v, %{
        minor: from_v.minor + 1,
        patch: 0
      })
      |> add_build_pre(options)
      |> to_string

    Version.parse!(new_version)
    new_version
  end

  def get_new_version({options, ["major"]}, from) do
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
    new_version
  end

  def get_new_version({_options, ["calver"]}, _from) do
    today = Date.utc_today()
    format = Config.calver_format()

    {:ok, new_version} = CalverFormattingParser.parse_format(format, today)
    new_version
  end

  def get_new_version({_, [version]}, _from) do
    Version.parse!(version) |> to_string
  end

  def get_new_version({options, []}, from) do
    from_v = Version.parse!(from)

    from_v
    |> add_build_pre(options)
    |> to_string
  end

  # Adds 'build' and 'pre' values to the `Version` struct of they were passed in options.
  @spec add_build_pre(Version.t(), Keyword.t()) :: Version.t()
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
end
