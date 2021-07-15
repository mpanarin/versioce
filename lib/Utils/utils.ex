defmodule Versioce.Utils do
  @spec deps_loaded?([module()]) :: true | false
  def deps_loaded?(deps) do
    deps
    |> Enum.map(&Code.ensure_loaded?(&1))
    |> Enum.all?()
  end
end
