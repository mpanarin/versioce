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

  @type t() :: %__MODULE__{
          added: [String.t()],
          changed: [String.t()],
          deprecated: [String.t()],
          removed: [String.t()],
          fixed: [String.t()],
          security: [String.t()],
          other: [String.t()]
        }

  @spec from_string_list([String.t()], map()) :: __MODULE__.t()
  def from_string_list(messages, anchors) do
    anchors = struct!(Anchors, anchors)

    messages
    |> Enum.reduce(
      %__MODULE__{},
      &add_to_section(&1, &2, anchors)
    )
  end

  @spec add_to_section(String.t(), __MODULE__.t(), Anchors.t()) :: __MODULE__.t()
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
