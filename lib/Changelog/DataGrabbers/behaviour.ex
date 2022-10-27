defmodule Versioce.Changelog.DataGrabber do
  @moduledoc """
  Behaviour for datagrabbers in versioce
  """
  alias Versioce.Changelog.DataGrabber.Version

  @doc """
  Gets data for changelog generation.
  """
  @callback get_versions(unreleased_to :: String.t()) :: {:ok, [Version.t()]} | {:error, any}
  @doc """
  Gets data for a single version.
  """
  @callback get_version(version :: String.t()) :: {:ok, Version.t()} | {:error, any}
end
