defmodule Versioce.Changelog.DataGrabber.Versions do
  # TODO: THIS SHOULD BE A STRUCT
  alias Versioce.Changelog.Sections

  @type t() :: [version()]
  @type version() :: %{
          version: String.t(),
          sections: Sections.t()
        }

  # TODO: make this spec a lot more verbose
  @doc """
  Creates `Versioce.Changelog.DataGrabber.Versions.version()` from commit group.
  """
  @spec make_version(map(), map()) :: version()
  def make_version(%{messages: messages} = commit_group, anchors) do
    %{
      version: commit_group.version,
      sections: Sections.from_string_list(messages, anchors)
    }
  end

  @doc """
  Swaps version number in `version()`
  """
  @spec re_version(version(), String.t()) :: version()
  def re_version(%{sections: sections}, new_version) do
    %{
      sections: sections,
      version: new_version
    }
  end
end
