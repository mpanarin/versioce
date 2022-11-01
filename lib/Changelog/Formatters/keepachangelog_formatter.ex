defmodule Versioce.Changelog.Formatter.Keepachangelog do
  @moduledoc """
  Keepachangelog formatter, `Versioce.Config.Changelog.formatter/0`

  Formats data obtained from `Versioce.Config.Changelog.datagrabber/0` into a Keepachagelog format.
  """
  @behaviour Versioce.Changelog.Formatter

  alias Versioce.Changelog.DataGrabber.Version
  alias Versioce.Config
  alias Versioce.Utils

  @unreleased_to "Unreleased"

  @impl Versioce.Changelog.Formatter
  @spec format(versions :: [Version.t()]) :: {:ok, String.t()}
  def format(versions) do
    with {:ok, header} <- make_header(),
         {:ok, body} <- make_body(versions),
         {:ok, footer} <- make_footer(versions) do
      {:ok, [header, body, footer] |> Enum.join("\n")}
    else
      error -> error
    end
  end

  @impl Versioce.Changelog.Formatter
  @spec version_to_str(Version.t()) :: String.t()
  def version_to_str(%{version: "HEAD"} = version),
    do: version |> Version.re_version(@unreleased_to) |> version_to_str()

  def version_to_str(%Version{version: version, sections: sections}) do
    """
    ## [#{version}]
    """
    |> Kernel.<>(
      sections
      |> Map.from_struct()
      |> Stream.filter(fn
        {_key, []} -> false
        {:other, _} -> !is_nil(Config.Changelog.unanchored_section())
        _ -> true
      end)
      |> Stream.map(fn
        {:other, strings} -> Config.Changelog.unanchored_section() |> section_to_str(strings)
        {key, strings} -> section_to_str(key, strings)
      end)
      |> Enum.to_list()
      |> Enum.join("\n")
    )
  end

  @doc """
  Generate keepachangelog header
  """
  @spec make_header() :: {:ok, String.t()}
  def make_header() do
    {:ok,
     """
     # Changelog
     All notable changes to this project will be documented in this file.

     The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)#{if Versioce.Config.Changelog.keepachangelog_semantic() do
       "\nThis project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)"
     end}
     """}
  end

  @doc """
  Generate keepachangelog body
  """
  @spec make_body(versions :: [Version.t()]) :: {:ok, String.t()}
  def make_body(versions) do
    {
      :ok,
      versions
      |> Enum.map_join("\n", &version_to_str/1)
    }
  end

  defp section_to_str(key, strings) do
    """
    ### #{key |> Atom.to_string() |> String.capitalize()}
    """
    |> Kernel.<>(
      strings
      |> Enum.map_join("\n", &"- #{&1}")
    )
    |> Kernel.<>("\n")
  end

  @doc """
  Generate keepachangelog footer.

  Requires the optional dependency `git_cli`.
  Can be skipped by setting `Versioce.Config.Changelog.git_origin/0` to `nil`.
  """
  @spec make_footer([Version.t()]) :: {:ok | :error, String.t()}
  def make_footer(versions) do
    git_origin = Config.Changelog.git_origin()

    with true <- Utils.deps_loaded?([Git]) or is_nil(git_origin) do
      make_footer(versions, git_origin)
    else
      false ->
        {:error,
         """
         Optional dependency `git_cli` is not loaded. It is required for Keepachangelog footer.

         If `git_cli` is not used, set the `git_origin` config option to nil

         ```
         config :versioce, :changelog,
             git_origin: nil
         ```
         """}
    end
  end

  defp make_footer(_versions, nil), do: {:ok, ""}

  defp make_footer(versions, _git_origin) do
    {
      :ok,
      versions
      |> version_names()
      |> append_inital_commit()
      |> Stream.chunk_every(2, 1, :discard)
      |> Stream.map(&make_footer_line/1)
      |> Enum.to_list()
      |> Enum.join("\n")
    }
  end

  @spec version_names(versions :: [Version.t()]) :: [String.t()]
  defp version_names(versions) do
    versions
    |> Enum.map(&Map.fetch!(&1, :version))
  end

  defp append_inital_commit(versions) do
    # NOTE: sadly, no way around it. Otherwise I'll get a bunch of annoying warnings
    # from dialyzer that Git functions are not defined
    {hash, _} = Code.eval_string("Versioce.Git.initial_commit()")

    versions ++ [hash]
  end

  defp make_footer_line(["HEAD" = hash1, hash2]) do
    "[#{@unreleased_to}]: #{Config.Changelog.git_origin()}/compare/#{hash2}...#{hash1}"
  end

  defp make_footer_line([hash1, hash2]) do
    "[#{hash1}]: #{Config.Changelog.git_origin()}/compare/#{hash2}...#{hash1}"
  end
end
