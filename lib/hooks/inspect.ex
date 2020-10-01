defmodule Versioce.PreHooks.InspectHook do
  @moduledoc """
  A simple hook inspecting its arguments.
  """
  use Versioce.PreHook

  @doc """
  Inspect its arguments. More of a helper|debugging hook.
  """
	def run(args) do
    IO.inspect(args)
  end
end

defmodule Versioce.PostHooks.InspectHook do
  @moduledoc """
  A simple hook inspecting its arguments.
  """
  use Versioce.PostHook

  @doc """
  Inspect its arguments. More of a helper|debugging hook.
  """
	def run(version) do
    IO.inspect(version)
  end
end
