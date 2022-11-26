defmodule Versioce.Config do
  @moduledoc """
  Configuration module for versioce app. Picks either a value from config.ex
  or a default.

  All config values take either a direct value or a function of arity 0 that will
  return the value.

  Other config namespaces:

  `Versioce.Config.Git`
  """

  import Versioce.Config.Macros, only: :macros

  value(
    :files,
    ["README.md"],
    "Files to be updated with new version. File paths should be relative to your `mix.exs`"
  )

  value(
    :global,
    false,
    "Whether the update will be global in file.\nBy default versioce will update only the first version in file it finds"
  )

  value(
    :calver_format,
    "YYYY.0M.0D",
    """
    What format to use for version when using CalVer.
    It should be still 3 values separated by a dot semver style.

    Available parts are:
    YYYY - Full year - 2006, 2016, 2106
    MM - Short month - 1, 2 ... 11, 12
    0M - Zero-padded month - 01, 02 ... 11, 12
    DD - Short day - 1, 2 ... 30, 31
    0D - Zero-padded day - 01, 02 ... 30, 31
    """
  )

  value(:pre_hooks, [], "Hooks to run before the version bumping")
  value(:post_hooks, [], "Hooks to run after the version bumping")

  defmodule Git do
    @moduledoc """
    Configuration module for versioce git integration.
    see `Versioce.Config` for more details
    """
    value(
      [:git, :dirty_add],
      false,
      "Whether to add all the files in `git add` or only from `Versioce.Config.files/0` and `Versioce.Config.Git.additional_files/0`. By default only `Versioce.Config.files/0`"
    )

    value(
      [:git, :additional_files],
      [],
      "Additional files to add in `git add`. No effect if `Versioce.Config.Git.dirty_add/0` is set to `true`"
    )

    value(
      [:git, :commit_message_template],
      "Bump version to {version}",
      "Template for the commit message. `{version}` will be replaced with the version you bumped to"
    )

    value(
      [:git, :tag_template],
      "{version}",
      "Template for the tag annotation. `{version}` will be replaced with the version you bumped to"
    )

    value(
      [:git, :tag_message_template],
      "Release version to {version}",
      "Template for the tag message. `{version}` will be replaced with the version you bumped to, `{tag_changelog} with relevant changelog part.`"
    )
  end

  defmodule Changelog do
    @moduledoc """
    Configuration module for versioce changelog generation.
    see `Versioce.Config` for more details
    """

    value(
      [:changelog, :datagrabber],
      Versioce.Changelog.DataGrabber.Git,
      "Data grabber for changelog generation. This data is further converted to a proper format with `Versioce.Config.Changelog.formatter/0`. For custom datagrabber see `Versioce.Changelog.DataGrabber`"
    )

    value(
      [:changelog, :anchors],
      %{
        added: ["[ADD]"],
        changed: ["[IMP]"],
        deprecated: ["[DEP]"],
        removed: ["[REM]"],
        fixed: ["[FIXED]"],
        security: ["[SEC]"]
      },
      "Anchors to look for in `Versioce.Changelog.DataGrabber.Git`. They will be converted to `Versioce.Changelog.Anchors` struct"
    )

    value(
      [:changelog, :formatter],
      Versioce.Changelog.Formatter.Keepachangelog,
      "Formatter for changelog generation. Formats data from grabbed by `Versioce.Config.Changelog.datagrabber`. For custom formatter see `Versioce.Changelog.Formatter`"
    )

    value(
      [:changelog, :unanchored_section],
      :other,
      "Section in changelog where unanchored entries should be placed. If `nil`, they are ignored and won't be added to the changelog. For more info see `Versioce.Changelog.Formatter.Keepachangelog`"
    )

    value(
      [:changelog, :changelog_file],
      "CHANGELOG.md",
      "File to put your changelog in. File path should be relative to your `mix.exs`"
    )

    value(
      [:changelog, :keepachangelog_semantic],
      true,
      "Whether the project adheres to Semantic Versioning. Used in a `Versioce.Changelog.Formatter.Keepachangelog`"
    )

    value(
      [:changelog, :git_origin],
      nil,
      "Project repository url for changelog footer generation. If nil, footer section will be ignored. For more info see `Versioce.Changelog.Formatter.Keepachangelog.make_footer/1`"
    )
  end
end
