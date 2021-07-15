# Versioce
[![Hex version badge](https://img.shields.io/hexpm/v/versioce.svg)](https://hex.pm/packages/versioce)
[![Actions Status](https://github.com/mpanarin/versioce/workflows/Elixir%20CI/badge.svg)](https://github.com/mpanarin/versioce/actions)
[![Code coverage badge](https://img.shields.io/codecov/c/github/mpanarin/versioce/master.svg)](https://codecov.io/gh/mpanarin/versioce/branch/master)
[![License badge](https://img.shields.io/hexpm/l/versioce.svg)](https://github.com/mpanarin/versioce/blob/master/LICENSE.md)

This is a mix task to bump version of your project.
Versioce includes batteries that are customizable for your liking.
It is heavily inspired by [bumpversion](https://github.com/peritus/bumpversion).

## Quick links
- [Installation](#installation)
- [Migrating from older versions](#migrating-from-older-versions)
- [Usage](#usage)
  - [Configure the files](#configure-the-files)
  - [Configure Hooks](#configure-hooks)
    - [Pre Hooks](#pre-hooks)
    - [Post Hooks](#post-hooks)
  - [Bump your versions!](#bump-your-versions)
  - [Changelog generation](#changelog-generation)
- [The name](#the-name)
- [Similar projects](#similar-projects)
- [Some acknowledgments](#some-acknowledgments)

## Installation

The [package](https://hex.pm/packages/versioce) can be installed by adding `versioce` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:versioce, "~> 1.1.1"}
  ]
end
```

## Migrating from older versions
Major versions bring braking changes or deprecations.
For migration instructions see [Migrations doc](docs/migrations.md)

## Usage

### Configure the files

You should let `Versioce` know what files you want your version bumped in.
By default only the files `README.md` and `mix.exs` are used.
You can add additional files to this list in the config
```elixir
config :versioce,
  files: [
    "README.md",
    "docker/Dockerfile"
  ]
```
> Note: All file paths should be relative to the `mix.exs` file. `mix.exs` will **always** be used and bumped
> as it is the **core** file, from which `versioce` will pick your current version. This was done in order
> to remove any additional config files (ex. `.bumpversion.cfg` in bumpversion).

### Configure Hooks

`Versioce` is agnostic of your VCS(although has hooks for git) or other things you need to do.
Some people want to generate changelogs, some - automatically notify teammates
at slack, publish package to hex, etc.

To make it possible - `Versioce` has Hooks. There are `pre` hooks and `post` hooks.
Hook is a list of simple elixir modules that have `run` function in them.

> Check other available configurations in [config docs](Versioce.Config.html)

#### Pre hooks

Are fired before any of the bumping is done.\
Check available built-in [pre hooks](docs/available_hooks.md#pre-hooks)\
They receive all the parameters for the `bump` task as a list of strings.
Which they can use for their side-effects. But they are **required** to return
this list.\
The result of the first hook will be piped into the next one.

```elixir
defmodule MyProj.Versioce.PreHook do
  use Versioce.PreHook
  def run(params) do
    IO.inspect(params)
    {:ok, params}
  end
end
```
And in your config:
```elixir
config :versioce,
  pre_hooks: [MyProj.Versioce.PreHook],
```
After that:
```
> mix bump.version
0.1.0
> mix bump patch
Running pre-hooks: [MyProj.Versioce.PreHook]
["patch"]
Bumping version from 0.1.0:
0.1.1
Running post-hooks: []
Done.
```

#### Post hooks

Work the same as pre hooks. The only differences are:
1. They are fired after all the version bumping
2. Their `run` function receives a `version` which was bumped to instead of params.\
Check available built-in [post hooks](docs/available_hooks.md#post-hooks)

```elixir
defmodule MyProj.Versioce.PostHook do
  use Versioce.PostHook
  def run(version) do
    IO.inspect(version)
    {:ok, version}
  end
end
```
And in your config:
```elixir
config :versioce,
  post_hooks: [MyProj.Versioce.PostHook],
```
After that:
```
> mix bump.version
0.1.0
> mix bump patch
Running pre-hooks: []
Bumping version from 0.1.0:
0.1.1
Running post-hooks: [MyProj.Versioce.PostHook]
"0.1.1"
Done.
```

### Bump your versions!

Simply run `mix bump` with the preferred binding or a ready version.
```
> mix bump.version
0.1.0
> mix bump patch
Running pre-hooks: []
Bumping version from 0.1.0:
0.1.1
Running post-hooks: []
Done.
> mix bump major
Running pre-hooks: []
Bumping version 0.1.1:
1.0.0
Running post-hooks: []
Done.
> mix bump 2.0.2
Running pre-hooks: []
Bumping version from 1.1.1:
2.0.2
Running post-hooks: []
Done.
```

You can also add pre-release or build information easily with `--pre` or `--build`
```
> mix bump.version
0.1.0
> mix bump --pre alpha.3
Running pre-hooks: []
Bumping version from 0.1.0:
0.1.1-alpha.3
Running post-hooks: []
Done.
> mix bump --build 20210101011700.amd64
Running pre-hooks: []
Bumping version from 0.1.1-alpha.3:
0.1.1-alpha.3+20210101011700.amd64
Running post-hooks: []
Done.
```

### Changelog generation

Versioce has the functionality to generate changelogs. By default it produces a changlog in the [Keepachangelog](https://keepachangelog.com/en/1.0.0/) format
from your Git history, but both can be configured:
``` elixir
config :versioce, :changelog,
  datagrabber: Versioce.Changelog.DataGrabber.Git,        # Or your own datagrabber module
  formatter: Versioce.Changelog.Formatter.Keepachangelog  # Or your own formatter module
```
Make sure to set the proper anchors configuration according to your repository policies, so Versioce can place entries in the proper sections:

``` elixir
config :versioce, :changelog,
  anchors:
      %{
        added: ["[ADD]"],
        changed: ["[IMP]"],
        deprecated: ["[DEP]"],
        removed: ["[REM]"],
        fixed: ["[FIXED]"],
        security: ["[SEC]"]
      }
```
> Anchors definition should follow the `Versioce.Changelog.Anchors` struct format. As it will be converted to it down the line.

And your are all set!
Now you can either run a `mix changelog` task to generate a changelog file
or add `Versioce.PostHooks.Changelog` post hook in your configuration:
``` elixir
config :versioce,
  post_hooks: [Versioce.PostHooks.Changelog],
```
> *Important*: If you want to use this hook in combination with `Versioce.PostHooks.Git.Release`, make sure that changelog is *before* the release hook, as well as either `Versioce.Config.Git.dirty_add/0` is enabled or your changelog file is added to `Versioce.Config.Git.additional_files/0`\
> Make sure to check other configurations for the changelog generation in `Versioce.Config.Changelog`

## The name

The name `Versioce` is a play on Italian brand Versace with a word version.\
It obviously has no connection to it.\
I obviously lack any creativity or imagination.

## Similar projects

  * https://github.com/glasnoster/eliver
  * https://github.com/oo6/mix-bump
  * https://github.com/zachdaniel/git_ops

## Some acknowledgments

A huge inspiration for this project was Elixir conf talk by Jeremy Searls\
Which I highly recommend you to [watch](https://www.youtube.com/watch?v=zTHCEZVL4Kw)
