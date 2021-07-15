defmodule VersioceTest.Changelog.Formatters.Keepachangelog do
  use ExUnit.Case, async: false
  alias Versioce.Changelog.Formatter.Keepachangelog

  setup do
    Application.put_env(:versioce, :changelog, [
      {:keepachangelog_semantic, true},
      {:unanchored_section, :uncategorised},
      {:git_origin, Mix.Project.config()[:source_url]}
    ])

    versions = [
      %{
        sections: %Versioce.Changelog.Sections{
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
        },
        version: "HEAD"
      },
      %{
        sections: %Versioce.Changelog.Sections{
          added: [
            "Initial commit"
          ],
          changed: [],
          deprecated: [],
          fixed: [],
          other: ["Bump version to 0.0.1"],
          removed: [],
          security: []
        },
        version: "v0.0.1"
      }
    ]

    %{
      versions: versions
    }
  end

  describe "make_header/0" do
    test "returns proper header with semantic" do
      assert {:ok,
              """
              # Changelog
              All notable changes to this project will be documented in this file.

              The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
              This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)
              """} = Keepachangelog.make_header()
    end

    test "returns proper header with no semantic" do
      Application.put_env(:versioce, :changelog, [
        {:keepachangelog_semantic, false}
      ])

      assert {:ok,
              """
              # Changelog
              All notable changes to this project will be documented in this file.

              The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
              """} = Keepachangelog.make_header()
    end
  end

  describe "make_body/1" do
    test "generates a proper body", %{versions: versions} do
      assert {:ok,
              """
              ## [Unreleased]
              ### Added
              - update ci config
              - Added tests after changelogs
              - Add Changelog generation, no tests for now

              ### Changed
              - changed something

              ### Deprecated
              - deprecated some endpoint

              ### Fixed
              - Some very interesting bug

              ### Uncategorised
              - Some random thing

              ### Removed
              - Something got dropped

              ### Security
              - Important security patch

              ## [v0.0.1]
              ### Added
              - Initial commit

              ### Uncategorised
              - Bump version to 0.0.1
              """} =
               versions
               |> Keepachangelog.make_body()
    end

    test "generates a proper body, respects unanchored_section config ", %{versions: versions} do
      Application.put_env(:versioce, :changelog, [
        {:unanchored_section, :"random name"}
      ])

      assert {:ok,
              """
              ## [Unreleased]
              ### Added
              - update ci config
              - Added tests after changelogs
              - Add Changelog generation, no tests for now

              ### Changed
              - changed something

              ### Deprecated
              - deprecated some endpoint

              ### Fixed
              - Some very interesting bug

              ### Random name
              - Some random thing

              ### Removed
              - Something got dropped

              ### Security
              - Important security patch

              ## [v0.0.1]
              ### Added
              - Initial commit

              ### Random name
              - Bump version to 0.0.1
              """} =
               versions
               |> Keepachangelog.make_body()
    end
  end

  describe "make_footer/1" do
    # TODO: add test for proper footer generation
    test "ignores footer if git_origin is nil", %{versions: versions} do
      Application.put_env(:versioce, :changelog, [
        {:git_origin, nil}
      ])

      assert {:ok, ""} = versions |> Keepachangelog.make_footer()
    end
  end
end
