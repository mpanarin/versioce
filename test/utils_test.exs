defmodule VersioceTest.Utils do
  use ExUnit.Case, async: false

  test "returns false if module is not loaded" do
    refute Versioce.Utils.deps_loaded?([Some.Non.Existing.Module])
  end

  test "returns true if module is loaded" do
    assert Versioce.Utils.deps_loaded?([Git])
  end

  test "returns true for several loaded modules" do
    assert Versioce.Utils.deps_loaded?([Git, Versioce.Config])
  end

  test "returns false if one of several modules is not loaded" do
    refute Versioce.Utils.deps_loaded?([Git, Versioce.Config, Some.Non.Existing.Module])
  end
end
