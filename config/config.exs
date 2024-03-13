import Config

config :versioce,
  files: ["mix.exs", "README.md"],
  post_hooks: [Versioce.PostHooks.Changelog, Versioce.PostHooks.Git.Release]

config :versioce, :git,
  additional_files: ["CHANGELOG.md"],
  commit_message_template: ":clap: Bump version to {version}",
  tag_template: "v{version}",
  tag_message_template: ":clap: Release v{version}\n{tag_changelog}"

config :versioce, :changelog,
  anchors: %{
    added: [
      ":sparkles:",  # Added new feature
      ":bulb:",  # Added/changed comments, etc.
      ":art:",  # Added/changed docs
      ":construction_worker:",  # CI stuff
      ":white_check_mark:",  # Added/changed tests
      ":construction:",  # wip commits
    ],
    changed: [
      ":recycle:",  # Code refactors
      ":children_crossing:",  # User experience improvements
      ":boom:"  # breaking changes
    ],
    deprecated: [":gun:"],
    removed: [
      ":fire:",  # code/files removal
      ":coffin:"  # dead code removal
    ],
    fixed: [":bug:"],
    security: [":rotating_light:"]
  },
  unanchored_section: :uncategorised,
  git_origin: Mix.Project.config()[:source_url]

import_config("#{Mix.env()}.exs")
