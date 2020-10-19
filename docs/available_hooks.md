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
Done.
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
Done.
```
### `Versioce.PostHooks.Git.Add`
Performs a `git add` operation in your repository
You can add it to your post_hooks in the config.
```elixir
config :versioce,
  post_hooks: [Versioce.PostHooks.Git.Add],
```

By default only adds files from `Versioce.Config.files` parameter in versioce config.\
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
