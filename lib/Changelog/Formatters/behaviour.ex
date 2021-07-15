defmodule Versioce.Changelog.Formatter do
  @moduledoc """
  Behaviour for formatters in versioce
  """
  alias Versioce.Changelog.DataGrabber.Versions

  @doc """
  Formats the `Versioce.Changelog.DataGrabber.Versions.t()` data for changelog
  """
  @callback format(versions :: Versions.t()) :: {:ok, String.t()} | {:error, any}
end
