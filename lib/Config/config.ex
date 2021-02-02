defmodule Versioce.Config do
  @moduledoc """
  Configuration module for versioce app. Picks either a value from config.ex
  or a default.

  All config values take either a direct value or a function of arity 0 that will
  return the value.
  """

  import Versioce.Config.Macros, only: :macros

  value :files, ["README.md"],
    "Files to be updated with new version"
  value :global, false,
    "Whether the update will be global in file.\nBy default versioce will update only the first version in file it finds"
  value :pre_hooks, [],
    "Hooks to run before the version bumping"
  value :post_hooks, [],
    "Hooks to run after the version bumping"

  defmodule Git do
    value [:git, :dirty_add], false,
      "Whether to add all the files in `git add` or only from `Versioce.Config.files`. By default only `Versioce.Config.files`"
    value [:git, :commit_message_template], "Bump version to {version}",
      "Template for the commit message. `{version}` will be replaced with the version you bumped to"
    value [:git, :tag_template], "{version}",
      "Template for the tag annotation. `{version}` will be replaced with the version you bumped to"
    value [:git, :tag_message_template], "Release version to {version}",
      "Template for the tag message. `{version}` will be replaced with the version you bumped to"
  end
end
