defmodule Versioce.PreHooks.Inspect do
  @moduledoc """
  A simple pre-hook inspecting its arguments.

  Mostly used for debugging
  """
  use Versioce.PreHook

	def run(args) do
    IO.inspect(args)
  end
end

defmodule Versioce.PostHooks.Inspect do
  @moduledoc """
  A simple post-hook inspecting its arguments.

  Mostly used for debugging
  """
  use Versioce.PostHook

	def run(version) do
    IO.inspect(version)
  end
end
