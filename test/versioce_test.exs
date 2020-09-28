defmodule VersioceTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  setup do
    %{
      current_version: Mix.Project.config()[:version]
    }
  end

  test "Current version task", fixture do
    assert capture_io(fn -> Mix.Task.run("bump.version") end) == fixture.current_version <> "\n"
  end
end
