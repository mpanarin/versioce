defmodule VersioceTest.Changelog.Formatters.Keepachangelog do
  use ExUnit.Case, async: false
  alias Versioce.Changelog.Formatter.Keepachangelog
  alias Versioce.Changelog.Sections
  import Versioce.Tests.Factory
  use Mimic

  setup do
    Application.put_env(:versioce, :changelog, [
      {:keepachangelog_semantic, true},
      {:unanchored_section, :uncategorised},
      {:git_origin, Mix.Project.config()[:source_url]}
    ])

    versions = [
      build(:version),
      build(:version,
        version: "v0.0.1",
        sections: %Sections{
          added: [
            "Initial commit"
          ],
          changed: [],
          deprecated: [],
          fixed: [],
          other: ["Bump version to 0.0.1"],
          removed: [],
          security: []
        }
      )
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
    test "ignores footer if git_origin is nil", %{versions: versions} do
      Application.put_env(:versioce, :changelog, [
        {:git_origin, nil}
      ])

      assert {:ok, ""} = versions |> Keepachangelog.make_footer()
    end

    test "generates proper footer" do
      stub_with(Versioce.Git, Versioce.Test.FakeRepository)
      {:ok, versions} = Versioce.Changelog.DataGrabber.Git.get_versions()

      footer =
        """
        [Unreleased]: https://github.com/mpanarin/versioce/compare/v1.0.0...HEAD
        [v1.0.0]: https://github.com/mpanarin/versioce/compare/v0.1.0...v1.0.0
        [v0.1.0]: https://github.com/mpanarin/versioce/compare/v0.0.2...v0.1.0
        [v0.0.2]: https://github.com/mpanarin/versioce/compare/v0.0.1...v0.0.2
        [v0.0.1]: https://github.com/mpanarin/versioce/compare/000...v0.0.1
        """
        |> String.trim_trailing()

      assert {:ok, ^footer} = versions |> Keepachangelog.make_footer()
    end
  end

  describe "format/1" do
    stub_with(Versioce.Git, Versioce.Test.FakeRepository)
    {:ok, versions} = Versioce.Changelog.DataGrabber.Git.get_versions()

    changelog =
      """
      # Changelog
      All notable changes to this project will be documented in this file.

      The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
      This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)

      ## [Unreleased]
      ### Added
      - :sparkles: unreleased change

      ## [v1.0.0]
      ### Fixed
      - :bug: bug fixed

      ### Removed
      - :coffin: dead code dropped

      ### Security
      - :rotating_light: security upgraded

      ## [v0.1.0]
      ### Changed
      - :children_crossing: improved accessibility
      - :recycle: refactored some code

      ### Deprecated
      - :gun: deprecated a feature

      ### Removed
      - :fire: files removed

      ## [v0.0.2]
      ### Added
      - :construction_worker: added CI
      - :construction: this is WIP
      - :art: improved formatting

      ## [v0.0.1]
      ### Added
      - :sparkles: added new feature
      - :white_check_mark: added tests
      - :bulb: initial commit

      [Unreleased]: https://github.com/mpanarin/versioce/compare/v1.0.0...HEAD
      [v1.0.0]: https://github.com/mpanarin/versioce/compare/v0.1.0...v1.0.0
      [v0.1.0]: https://github.com/mpanarin/versioce/compare/v0.0.2...v0.1.0
      [v0.0.2]: https://github.com/mpanarin/versioce/compare/v0.0.1...v0.0.2
      [v0.0.1]: https://github.com/mpanarin/versioce/compare/000...v0.0.1
      """
      |> String.trim_trailing()

    assert {:ok, ^changelog} = versions |> Keepachangelog.format()
  end
end
