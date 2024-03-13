import Config

config :versioce,
  post_hooks: [Versioce.PostHooks.Changelog, Versioce.PostHooks.Git.Release]

config :versioce, :git,
  additional_files: ["CHANGELOG.md"],
  commit_message_template: ":clap: Bump version to {version}",
  tag_template: "v{version}",
  tag_message_template: ":clap: Release v{version}\n{tag_changelog}"

config :versioce, :changelog,
  anchors: %{
    added: [
      ":sparkles:",
      ":bulb:",
      ":art:",
      ":construction_worker:",
      ":white_check_mark:",
      ":construction:"
    ],
    changed: [":recycle:", ":children_crossing:"],
    deprecated: [":gun:"],
    removed: [":fire:", ":coffin:"],
    fixed: [":bug:"],
    security: [":rotating_light:"]
  },
  unanchored_section: :uncategorised,
  git_origin: Mix.Project.config()[:source_url]

import_config("#{Mix.env()}.exs")
