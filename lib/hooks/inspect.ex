defmodule Versioce.InspectHook do
  @moduledoc """
  A simple hook inspecting its arguments.
  """

  @doc """
  Inspect its arguments. More of a helper|debugging hook.
  """
	def run(arg) do
    IO.inspect(arg)
  end
end
