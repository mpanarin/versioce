# Migrating from `< 3.0.0`
Version `3.0.0` introduced breaking changes:
1. `mix.exs` is no longer part of default `files`
For the same behavior as before add `mix.exs` to `files` in config
```elixir
config :versioce,
  files: ["mix.exs", "README.md"]
```
2. Default message for `tag_message_template` configuration changed.
For the same behavior as before
```elixir
config :versioce, :git,
  tag_message_template: "Release version to {version}"
```

# Migrating from `< 2.0.0`
Version `2.0.0` added a breaking change to changelog generation behaviors.

#### Now `Versioce.Changelog.DataGrabber`
Should implement `get_versions/1` instead of `get_data/1`.
Should implement `get_version/1` that will grab data for one specific version.

For implementation details check out `Versioce.Changelog.DataGrabber.Git`

#### Now `Versioce.Changelog.Formatter`
Should implement `version_to_str/1` which will format single `Versioce.Changelog.DataGrabber.Version.t()` to string.

For implementation details check out `Versioce.Changelog.Formatter.Keepachangelog`

# Migrating from `< 1.0.0`
Version `1.0.0` added a breaking change in terms of hook running.
Hooks changed their signature. Now they should follow the general `{:ok, params} | {:error, reason}` tuples pattern.
Ex.:
``` elixir
defmodule MyProj.PreHook do
  use Versioce.PreHook

  def run(params) do
    {:ok, params}
  end
end
```
> Note: All hooks should still pass on parameters they recieved in an `:ok` tuple.
> If one of the hooks fails and returns `:error` tuple, bumping stops and `reason` will be shown.

`git_cli` is no longer a mandatory dependency. If you don't use Versioce git hooks, you can drop it.
