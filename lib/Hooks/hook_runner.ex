defmodule Versioce.Hooks do
  @moduledoc false
  import Versioce.OK, only: :macros

  @spec run(any, [module()]) :: Versioce.OK.t()
  def run(params, []), do: Versioce.OK.unit(params)

  def run(params, [hook | hooks]) do
    params
    ~>> hook.run
    |> run(hooks)
  end
end
