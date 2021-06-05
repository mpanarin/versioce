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
