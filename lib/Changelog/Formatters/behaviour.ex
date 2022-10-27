defmodule Versioce.Changelog.Formatter do
  @moduledoc """
  Behaviour for formatters in versioce
  """
  alias Versioce.Changelog.DataGrabber.Version

  @doc """
  Formats the `[Versioce.Changelog.DataGrabber.Version.t()]` data for changelog
  """
  @callback format(versions :: [Version.t()]) :: {:ok, String.t()} | {:error, any}

  @doc """
  Formats the `Versioce.Changelog.DataGrabber.Version.t()` data for changelog
  """
  @callback version_to_str(version :: Version.t()) :: String.t()
end
