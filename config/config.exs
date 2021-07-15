import Config

config :versioce,
  files: ["README.md"],
  global: false,
  pre_hooks: [],
  post_hooks: [Versioce.PostHooks.Changelog, Versioce.PostHooks.Git.Release]

config :versioce, :git,
  commit_message_template: ":clap: Bump version to {version}",
  tag_template: "v{version}",
  tag_message_template: ":clap: Release v{version}",
  additional_files: ["CHANGELOG.md"]

config :versioce, :changelog,
  datagrabber: Versioce.Changelog.DataGrabber.Git,
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
  keepachangelog_semantic: false,
  git_origin: Mix.Project.config()[:source_url]

import_config("#{Mix.env()}.exs")
