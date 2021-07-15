defmodule VersioceTest.Changelog.Sections do
  use ExUnit.Case, async: true

  alias Versioce.Changelog.Sections

  setup do
    anchors = %{
      added: ["[ADD]"],
      changed: ["[IMP]"],
      deprecated: ["[DEP]"],
      removed: ["[REM]"],
      fixed: ["[FIXED]"],
      security: ["[SEC]"]
    }

    messages = [
      "[ADD] and another thing",
      "[SEC] security patch",
      "[DEP] deprecated something",
      "[ADD] added something",
      "random message",
      "[FIXED] epic bugfix",
      "[IMP] random improvement",
      "[REM] removed some code"
    ]

    %{
      anchors: anchors,
      messages: messages
    }
  end

  test "from_string_list/2", %{
    anchors: anchors,
    messages: messages
  } do
    assert %Sections{
             added: [
               "[ADD] and another thing",
               "[ADD] added something"
             ],
             changed: ["[IMP] random improvement"],
             deprecated: ["[DEP] deprecated something"],
             removed: ["[REM] removed some code"],
             fixed: ["[FIXED] epic bugfix"],
             security: ["[SEC] security patch"],
             other: ["random message"]
           } = Sections.from_string_list(messages, anchors)
  end
end
