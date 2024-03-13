defmodule Versioce.Config do
  @moduledoc """
  Configuration module for versioce app. Picks either a value from config.ex
  or a default.

  All config values take either a direct value or a function of arity 0 that will
  return the value.

  Other config namespaces:

  `Versioce.Config.Git`
  `Versioce.Config.Changelog`
  """

  import Versioce.Config.Macros, only: :macros
  alias Versioce.Config.Macros.Description

  value(
    :files,
    ["README.md"],
    %Description{
      description: "Files to be updated with new version. File paths should be relative to your `mix.exs`",
    }
  )

  value(
    :global,
    false,
    %Description{
      description: "Whether the update will be global in file.\nBy default versioce will update only the first version in file it finds",
      example: true
    }
  )

  value(
    :calver_format,
    "YYYY.0M.0D",
    %Description{
      description: """
      What format to use for version when using CalVer.
      It should be still 3 values separated by a dot semver style.

      Available parts are:
      YYYY - Full year - 2006, 2016, 2106
      MM - Short month - 1, 2 ... 11, 12
      0M - Zero-padded month - 01, 02 ... 11, 12
      DD - Short day - 1, 2 ... 30, 31
      0D - Zero-padded day - 01, 02 ... 30, 31
      """,
      example: "YYYY_MM_DD"
    }
  )

  value(
    :pre_hooks,
    [],
    %Description{
      description: "Hooks to run before the version bumping",
      example: [Versioce.PreHooks.Inspect]
    }
  )

  value(
    :post_hooks,
    [],
    %Description{
      description: "Hooks to run after the version bumping",
      example: [Versioce.PostHooks.Inspect]
    }
  )

  defmodule Git do
    @moduledoc """
    Configuration module for versioce git integration.
    see `Versioce.Config` for more details
    """
    value(
      [:git, :dirty_add],
      false,
      %Description{
        description: "Whether to add all the files in `git add` or only from `Versioce.Config.files/0` and `Versioce.Config.Git.additional_files/0`. By default only `Versioce.Config.files/0`",
        example: true
      }
    )

    value(
      [:git, :additional_files],
      [],
      %Description{
        description: "Additional files to add in `git add`. No effect if `Versioce.Config.Git.dirty_add/0` is set to `true`",
        example: ["CHANGELOG.md"]
      }
    )

    value(
      [:git, :commit_message_template],
      "Bump version to {version}",
      %Description{
        description: "Template for the commit message. `{version}` will be replaced with the version you bumped to",
        example: "Bumping my awesome app to {version}"
      }
    )

    value(
      [:git, :tag_template],
      "{version}",
      %Description{
        description: "Template for the tag annotation. `{version}` will be replaced with the version you bumped to",
        example: "v{version}"
      }
    )

    value(
      [:git, :tag_message_template],
      "Release {version}",
      %Description{
        description: "Template for the tag message. `{version}` will be replaced with the version you bumped to, `{tag_changelog} with relevant changelog part.`",
        example: "v{version}\n{tag_changelog}"
      }
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
      %Description{
        description: "Data grabber for changelog generation. This data is further converted to a proper format with `Versioce.Config.Changelog.formatter/0`. For custom datagrabber see `Versioce.Changelog.DataGrabber`",
      }
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
      %Description{
        description: "Anchors to look for in `Versioce.Changelog.DataGrabber.Git`. They will be converted to `Versioce.Changelog.Anchors` struct",
      }
    )

    value(
      [:changelog, :formatter],
      Versioce.Changelog.Formatter.Keepachangelog,
      %Description{
        description: "Formatter for changelog generation. Formats data from grabbed by `Versioce.Config.Changelog.datagrabber`. For custom formatter see `Versioce.Changelog.Formatter`",
      }
    )

    value(
      [:changelog, :unanchored_section],
      :other,
      %Description{
        description: "Section in changelog where unanchored entries should be placed. If `nil`, they are ignored and won't be added to the changelog. For more info see `Versioce.Changelog.Formatter.Keepachangelog`",
      }
    )

    value(
      [:changelog, :changelog_file],
      "CHANGELOG.md",
      %Description{
        description: "File to put your changelog in. File path should be relative to your `mix.exs`",
        example: "OTHERFILE.md"
      }
    )

    value(
      [:changelog, :keepachangelog_semantic],
      true,
      %Description{
        description: "Whether the project adheres to Semantic Versioning. Used in a `Versioce.Changelog.Formatter.Keepachangelog`",
        example: false
      }
    )

    value(
      [:changelog, :git_origin],
      nil,
      %Description{
        description: "Project repository url for changelog footer generation. If nil, footer section will be ignored. For more info see `Versioce.Changelog.Formatter.Keepachangelog.make_footer/1`",
        example: Mix.Project.config()[:source_url]
      }
    )
  end
end
