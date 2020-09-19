import Config

config :versioce,
  files: ["README.md"],
  pre_hooks: [],
  post_hooks: []


import_config("#{Mix.env()}.exs")
