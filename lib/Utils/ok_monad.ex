defmodule Versioce.OK do
  @moduledoc false

  @type ok_tuple :: {:ok, any} | {:error, any}

  @spec bind(ok_tuple, fun) :: ok_tuple()
  def bind({:ok, value}, func), do: func.(value)
  def bind({:error, reason}, _), do: {:error, reason}

  @spec unit(any) :: ok_tuple()
  def unit({:ok, _} = value), do: value
  def unit({:error, _} = value), do: value
  def unit(value), do: {:ok, value}
end
