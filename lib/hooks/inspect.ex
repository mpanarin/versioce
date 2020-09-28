defmodule Versioce.InspectHook do
  @moduledoc """
  A simple hook inspecting its arguments.
  """

	def run(arg) do
    IO.inspect(arg)
  end
end
