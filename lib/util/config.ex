defmodule Versioce.Config do
  @moduledoc false

  @doc false
  def files do
    case Application.fetch_env(:versioce, :files) do
      {:ok, value} -> value
      :error -> ["README.md"]
    end
  end

  @doc false
  def global do
    case Application.fetch_env(:versioce, :global) do
      {:ok, value} -> value
      :error -> false
    end
  end

  @doc false
  def pre_hooks do
    case Application.fetch_env(:versioce, :pre_hooks) do
      {:ok, value} -> value
      :error -> []
    end
  end

  @doc false
  def post_hooks do
    case Application.fetch_env(:versioce, :post_hooks) do
      {:ok, value} -> value
      :error -> []
    end
  end
end
