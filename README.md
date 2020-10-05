# Versioce
[![Hex version badge](https://img.shields.io/hexpm/v/versioce.svg)](https://hex.pm/packages/versioce)
[![Actions Status](https://github.com/mpanarin/versioce/workflows/Elixir%20CI/badge.svg)](https://github.com/mpanarin/versioce/actions)
[![Code coverage badge](https://img.shields.io/codecov/c/github/mpanarin/versioce/master.svg)](https://codecov.io/gh/mpanarin/versioce/branch/master)
[![License badge](https://img.shields.io/hexpm/l/versioce.svg)](https://github.com/mpanarin/versioce/blob/master/LICENSE.md)

This is a simple mix task to bump version of your project.
It is heavily inspired by [bumpversion](https://github.com/peritus/bumpversion).

## Installation

The [package](https://hex.pm/packages/versioce) can be installed by adding `versioce` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:versioce, "~> 0.1.1"}
  ]
end
```

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

`Versioce` is agnostic of your VCS(as of now) or other things you need to do.
Some people want to generate changelogs, some - automatically notify teammates
at slack, publish package to hex, etc.

To make it possible - `Versioce` has Hooks. There are `pre` hooks and `post` hooks.
Hook is a list of simple elixir modules that have `run` function in them.

#### Pre hooks

Are fired before any of the bumping is done.
They receive all the parameters for the `bump` task as a list of strings.
Which they can use for their side-effects. But they are **required** to return
this list.\
The result of the first hook will be piped into the next one.

```elixir
defmodule MyProj.Versioce.PreHook do
  use Versioce.PreHook
  def run(params) do
    IO.inspect(params)
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
2. Their `run` function receives a `version` which was bumped to instead of params.

```elixir
defmodule MyProj.Versioce.PostHook do
  use Versioce.PostHook
  def run(version) do
    IO.inspect(version)
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
