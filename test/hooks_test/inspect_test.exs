defmodule VersioceTest.Hooks.Inspect do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO

  test "Inspect pre hook" do
    assert capture_io(fn ->
             assert Versioce.PreHooks.Inspect.run(["minor"]) == {:ok, ["minor"]}
           end) == "[\"minor\"]\n"
  end

  test "Inspect post hook" do
    assert capture_io(fn ->
             assert Versioce.PostHooks.Inspect.run("0.1.0") == {:ok, "0.1.0"}
           end) == "\"0.1.0\"\n"
  end
end
