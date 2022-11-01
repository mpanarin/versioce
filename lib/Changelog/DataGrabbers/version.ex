defmodule Versioce.Changelog.DataGrabber.Version do
  alias Versioce.Changelog.Sections
  alias Versioce.Changelog.DataGrabber.Version, as: VersioceVersion

  @enforce_keys [:version, :sections]
  defstruct version: "", sections: []

  @type t() :: %__MODULE__{
          version: String.t(),
          sections: Sections.t()
        }

  @doc """
  Creates `Versioce.Changelog.DataGrabber.Version.t()` from commit group.
  """
  @spec make_version(
          Versioce.Changelog.DataGrabber.Git.commit_group(),
          Versioce.Changelog.Anchors.t()
        ) :: t()
  def make_version(%{messages: messages, version: version}, anchors) do
    %VersioceVersion{
      version: version,
      sections: Sections.from_string_list(messages, anchors)
    }
  end

  @doc """
  Swaps version number in `t()`
  """
  @spec re_version(t(), String.t()) :: t()
  def re_version(%VersioceVersion{sections: sections}, new_version) do
    %VersioceVersion{
      sections: sections,
      version: new_version
    }
  end
end
