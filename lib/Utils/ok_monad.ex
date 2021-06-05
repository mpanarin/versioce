defmodule Versioce.OK do
  @moduledoc false

  @type t :: {:ok, any} | {:error, any}

  @doc """
  Wraps and unwraps the value in ok tuple.
  """
  @spec unit(any) :: t()
  def unit({:ok, _} = value), do: value
  def unit({:error, _} = value), do: value
  def unit(value), do: {:ok, value}

  @doc """
  Bind operator.

  Runs a given func against the ok_tuple.
  If its the error tuple -> skip evaluation
  """
  defmacro left ~>> right do
    quote do
      unquote(left)
      |> Versioce.OK.unit()
      |> (fn
            {:ok, value} -> value |> unquote(right)
            {:error, reason} -> {:error, reason}
          end).()
    end
  end
end
