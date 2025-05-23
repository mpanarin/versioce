# Available Hooks

## Pre Hooks

### `Versioce.PreHooks.Inspect`

This is a simple hook that will inspect its argument. Meant for debugging purposes\
You can add it to your pre_hooks in the config.
```elixir
config :versioce,
  pre_hooks: [Versioce.PreHooks.Inspect],
```

```
> mix bump patch
Running pre-hooks: [Versioce.PreHooks.Inspect]
["patch"]
Bumping version from 0.1.0:
0.1.1
Running post-hooks: []
```

## Post Hooks

### `Versioce.PostHooks.Inspect`

This is a simple hook that will inspect its argument. Meant for debugging purposes\
You can add it to your post_hooks in the config.
```elixir
config :versioce,
  post_hooks: [Versioce.PostHooks.Inspect],
```

```
> mix bump patch
Running pre-hooks: []
Bumping version from 0.1.0:
0.1.1
Running post-hooks: [Versioce.PostHooks.Inspect]
["0.1.1"]
```

### `Versioce.PostHooks.Git.Add`

Performs a `git add` operation in your repository
You can add it to your post_hooks in the config.
```elixir
config :versioce,
  post_hooks: [Versioce.PostHooks.Git.Add],
```

By default only adds files from `Versioce.Config.files/0` parameter in versioce config.\
You can enable dirty add in configuration:
```elixir
config :versioce, :git,
  dirty_add: true
```

### `Versioce.PostHooks.Git.Commit`

Performs a `git commit -m` operation in the repository.
You can configure the commit message template in your config
```elixir
config :versioce, :git,
  commit_message_template: "Bump version to {version}"
```
`{version}` here will be replaced with the new version

### `Versioce.PostHooks.Git.Tag`

Performs a `git tag -a -m` operation in the repository.
You can configure the tag template and message template in your config
```elixir
config :versioce, :git,
  tag_template: "v{version}",
  tag_message_template: "Release v{version}"
```
`{version}` here will be replaced with the new version

### `Versioce.PostHooks.Git.Release`

Creates a git release. It is an alias for `[Versioce.PostHooks.Git.Add, Versioce.PostHooks.Git.Commit, Versioce.PostHooks.Git.Tag]`\
You can configure the messages
You can add it to your post_hooks in the config.
```elixir
config :versioce,
  post_hooks: [Versioce.PostHooks.Git.Release],
```

### `Versioce.PostHooks.Changelog`

Generates a changelog file at `Versioce.Config.Changelog.changelog_file/0`.\
There is a lot of configuration for the changelog generation, see `Versioce.Config.Changelog` for all the options.

By default this hook uses `Versioce.Changelog.Datagrabber.Git` datagrabber and `Versioce.Changelog.Formatter.Keepachangelog` formatter, using your git history to generate changelog.
You can change or write your own Formatter(`Versioce.Changelog.Formatter`) or Datagrabber(`Versioce.Changelog.Datagrabber`) and set them in config
```elixir
config :versioce, :changelog,
  datagrabber: Versioce.Changelog.DataGrabber.Git,        # Or your own datagrabber
  formatter: Versioce.Changelog.Formatter.Keepachangelog  # Or your own formatter
```
