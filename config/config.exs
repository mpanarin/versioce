import Config

config :versioce,
  files: ["README.md"],
  global: false,
  pre_hooks: [],
  post_hooks: [Versioce.PostHooks.ReleaseHook]

config :versioce, :git,
  commit_message_template: ":clap: Bump version to {version}",
  tag_template: "v{version}",
  tag_message_template: ":clap: Release v{version}"

import_config("#{Mix.env()}.exs")
