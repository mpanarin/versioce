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

  @spec add_to_section(String.t(), t(), Anchors.t()) :: __MODULE__.t()
  defp add_to_section(message, sections, anchors) do
    # TODO: Write an util funciton for this.
    Enum.reduce_while(anchors |> Map.from_struct(), sections, fn {section, anchor_strings}, _ ->
      Enum.reduce_while(anchor_strings, false, fn anchor, _ ->
        cond do
          Regex.match?(~r/^#{Regex.escape(anchor)}/, message) -> {:halt, section}
          true -> {:cont, false}
        end
      end)
      |> case do
        false -> {:cont, false}
        section -> {:halt, Map.update!(sections, section, &(&1 ++ [message]))}
      end
    end)
    |> case do
      false -> Map.update!(sections, :other, &([message] ++ &1))
      other -> other
    end
  end
end
