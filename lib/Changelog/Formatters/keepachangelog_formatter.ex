defmodule Versioce.Changelog.Formatter.Keepachangelog do
  @moduledoc """
  Keepachangelog formatter, `Versioce.Config.Changelog.formatter/0`

  Formats data obtained from `Versioce.Config.Changelog.datagrabber/0` into a Keepachagelog format.
  """
  @behaviour Versioce.Changelog.Formatter

  alias Versioce.Changelog.DataGrabber.Versions
  alias Versioce.Config
  alias Versioce.Utils

  @unreleased_to "Unreleased"

  @impl Versioce.Changelog.Formatter
  @spec format(versions :: [Versions.t()]) :: {:ok, String.t()}
  def format(versions) do
    with {:ok, header} <- make_header(),
         {:ok, body} <- make_body(versions),
         {:ok, footer} <- make_footer(versions) do
      {:ok, [header, body, footer] |> Enum.join("\n")}
    else
      error -> error
    end
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

     The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
     #{
       if Versioce.Config.Changelog.keepachangelog_semantic() do
         "This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)"
       else
         ""
       end
     }
     """}
  end

  @doc """
  Generate keepachangelog body
  """
  @spec make_body(versions :: Versions.t()) :: {:ok, String.t()}
  def make_body(versions) do
    {
      :ok,
      versions
      |> Enum.map(&version_to_str/1)
      |> Enum.join("\n")
    }
  end

  @spec version_to_str(Versions.version()) :: String.t()
  defp version_to_str(%{version: "HEAD", sections: sections}),
    do:
      version_to_str(%{
        version: @unreleased_to,
        sections: sections
      })

  defp version_to_str(version) do
    """
    ## [#{version.version}]
    """
    |> Kernel.<>(
      version.sections
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

  defp section_to_str(key, strings) do
    """
    ### #{key |> Atom.to_string() |> String.capitalize()}
    """
    |> Kernel.<>(
      strings
      |> Enum.map(&"- #{&1}")
      |> Enum.join("\n")
    )
    |> Kernel.<>("\n")
  end

  @doc """
  Generate keepachangelog footer.

  Requires the optional dependency `git_cli`
  """
  @spec make_footer(Versions.t()) :: {:ok | :error, String.t()}
  def make_footer(versions) do
    with true <- Utils.deps_loaded?([Git]) do
      {
        :ok,
        versions
        |> version_names()
        |> Kernel.++([Versioce.Git.initial_commit()])
        |> Stream.chunk_every(2, 1, :discard)
        |> Stream.map(&make_footer_line/1)
        |> Enum.to_list()
        |> Enum.join("\n")
      }
    else
      false ->
        {:error,
         "Optional dependency `git_cli` is not loaded. It is required for Keepachangelog footer"}
    end
  end

  @spec version_names(versions :: Versions.t()) :: [String.t()]
  defp version_names(versions) do
    versions
    |> Enum.map(&Map.fetch!(&1, :version))
  end

  defp make_footer_line(["HEAD" = hash1, hash2]) do
    "[#{@unreleased_to}]: #{Config.Changelog.git_origin()}/compare/#{hash2}...#{hash1}"
  end

  defp make_footer_line([hash1, hash2]) do
    "[#{hash1}]: #{Config.Changelog.git_origin()}/compare/#{hash2}...#{hash1}"
  end
end
