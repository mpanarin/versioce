defmodule Versioce.Changelog.Anchors do
  @moduledoc """
  Struct representation of commit message anchors types.
  """
  @enforce_keys [:added, :changed, :deprecated, :removed, :fixed, :security]
  defstruct [:added, :changed, :deprecated, :removed, :fixed, :security]

  @type t() :: %__MODULE__{
          added: [String.t()],
          changed: [String.t()],
          deprecated: [String.t()],
          removed: [String.t()],
          fixed: [String.t()],
          security: [String.t()]
        }
end
