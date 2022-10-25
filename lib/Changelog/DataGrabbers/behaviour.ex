defmodule Versioce.Changelog.DataGrabber do
  @moduledoc """
  Behaviour for datagrabbers in versioce
  """
  alias Versioce.Changelog.DataGrabber.Versions

  @doc """
  Gets data for changelog generation, returns `Versioce.Changelog.DataGrabber.Versions.t()` format.
  """
  @callback get_versions(unreleased_to :: String.t()) :: {:ok, Versions.t()} | {:error, any}
end
