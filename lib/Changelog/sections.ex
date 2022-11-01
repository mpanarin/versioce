defmodule Versioce.Changelog.Sections do
  alias Versioce.Changelog.Anchors
  @moduledoc false
  defstruct added: [],
            changed: [],
            deprecated: [],
            removed: [],
            fixed: [],
            security: [],
            other: []

  @typedoc """
  List of messages for a single section.
  """
  @type section() :: [String.t()]

  @typedoc """
  Struct of sections.
  Every section is a `section()`.
  """
  @type t() :: %__MODULE__{
          added: section(),
          changed: section(),
          deprecated: section(),
          removed: section(),
          fixed: section(),
          security: section(),
          other: section()
        }

  @spec from_string_list([String.t()], Anchors.t()) :: __MODULE__.t()
  def from_string_list(messages, anchors) do
    messages
    |> Enum.reduce(
      %__MODULE__{},
      &add_to_section(&1, &2, anchors)
    )
  end

  # Adds message to its proper section.
  # A message can only be in one section, the first anchor will be used
  @spec add_to_section(String.t(), t(), Anchors.t()) :: __MODULE__.t()
  defp add_to_section(message, sections, anchors) do
    section_name =
      Enum.reduce_while(Map.from_struct(anchors), sections, fn {section_name, _} = anchor, _ ->
        if in_section?(anchor, message) do
          {:halt, section_name}
        else
          {:cont, :other}
        end
      end)

    Map.update!(sections, section_name, &(&1 ++ [message]))
  end

  @spec in_section?({atom(), [String.t()]}, String.t()) :: boolean()
  defp in_section?({_, anchor_strings}, message) do
    anchor_strings
    |> Stream.map(fn anchor ->
      Regex.match?(~r/^#{Regex.escape(anchor)}/, message)
    end)
    |> Enum.any?()
  end
end
