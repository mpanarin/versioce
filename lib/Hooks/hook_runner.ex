defmodule Versioce.Hooks do
  @moduledoc false

  @spec run(any, [module()]) :: Versioce.OK.ok_tuple()
  def run(params, []), do: Versioce.OK.unit(params)

  def run(params, [h | tail]) do
    params
    |> Versioce.OK.unit()
    |> Versioce.OK.bind(&h.run/1)
    |> run(tail)
  end
end
