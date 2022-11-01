defmodule ChangelogTests.VersionTest do
  use ExUnit.Case, async: true
  alias Versioce.Changelog.DataGrabber.Version, as: ChangelogVersion
  import Versioce.Tests.Factory

  setup do
    %{
      anchors: build(:anchors),
      commit_group: build(:commit_group)
    }
  end

  test "make_version/2 properly generates a version", %{
    anchors: anchors,
    commit_group: %{version: version} = commit_group
  } do
    assert %ChangelogVersion{
             version: ^version,
             sections: %Versioce.Changelog.Sections{
               added: ["[ADD] and another thing", "[ADD] added something"],
               changed: ["[IMP] random improvement"],
               deprecated: ["[DEP] deprecated something"],
               fixed: ["[FIXED] epic bugfix"],
               other: ["random message"],
               removed: ["[REM] removed some code"],
               security: ["[SEC] security patch"]
             }
           } = ChangelogVersion.make_version(commit_group, anchors)
  end

  test "re_version/1 properly changes version", %{
    anchors: anchors,
    commit_group: commit_group
  } do
    assert %ChangelogVersion{version: "2.0.0"} =
             ChangelogVersion.make_version(commit_group, anchors)
             |> ChangelogVersion.re_version("2.0.0")
  end
end
