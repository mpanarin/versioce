defmodule Versioce.Tests.Factory do
  @moduledoc false

  use ExMachina
  alias Versioce.Changelog.Anchors
  alias Versioce.Changelog.DataGrabber.Version
  alias Versioce.Changelog.Sections

  def anchors_factory do
    %Anchors{
      added: ["[ADD]"],
      changed: ["[IMP]"],
      deprecated: ["[DEP]"],
      removed: ["[REM]"],
      fixed: ["[FIXED]"],
      security: ["[SEC]"]
    }
  end

  def commit_group_factory do
    %{
      version: "0.0.1",
      messages: [
        "[ADD] and another thing",
        "[SEC] security patch",
        "[DEP] deprecated something",
        "[ADD] added something",
        "random message",
        "[FIXED] epic bugfix",
        "[IMP] random improvement",
        "[REM] removed some code"
      ]
    }
  end

  def sections_factory do
    %Sections{
      added: [
        "update ci config",
        "Added tests after changelogs",
        "Add Changelog generation, no tests for now"
      ],
      changed: ["changed something"],
      deprecated: ["deprecated some endpoint"],
      fixed: ["Some very interesting bug"],
      other: ["Some random thing"],
      removed: ["Something got dropped"],
      security: ["Important security patch"]
    }
  end

  def version_factory do
    %Version{
      version: "HEAD",
      sections: build(:sections)
    }
  end
end
