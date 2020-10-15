defmodule VersioceTest do
  use ExUnit.Case, async: false
  import ExUnit.CaptureIO

  setup do
    %{
      current_version: Mix.Project.config()[:version]
    }
  end

  test "Current version task", fixture do
    assert capture_io(fn -> Mix.Task.rerun("bump.version") end) == fixture.current_version <> "\n"
  end

  describe "Version bumping task" do

    test "No hooks, only bump", fixture do
      Application.put_all_env([
        {:versioce, [
            {:pre_hooks, []},
            {:post_hooks, []},
          ]}
      ])

      assert capture_io(fn -> Mix.Task.rerun("bump", ["0.1.0"]) end) == """
      Running pre-hooks: []
      Bumping version from #{fixture.current_version}:
      "0.1.0"
      Running post-hooks: []
      """
    end

    test "Bumping with pre hooks", fixture do
      Application.put_all_env([
        {:versioce, [
            {:pre_hooks, [Versioce.PreHooks.InspectHook]},
            {:post_hooks, []},
          ]}
      ])

      assert capture_io(fn -> Mix.Task.rerun("bump", ["0.1.0"]) end) == """
      Running pre-hooks: [Versioce.PreHooks.InspectHook]
      ["0.1.0"]
      Bumping version from #{fixture.current_version}:
      "0.1.0"
      Running post-hooks: []
      """
    end

    test "Bumping with post hooks", fixture do
      Application.put_all_env([
        {:versioce, [
            {:pre_hooks, []},
            {:post_hooks, [Versioce.PostHooks.InspectHook]},
          ]}
      ])

      assert capture_io(fn -> Mix.Task.rerun("bump", ["0.1.0"]) end) == """
      Running pre-hooks: []
      Bumping version from #{fixture.current_version}:
      "0.1.0"
      Running post-hooks: [Versioce.PostHooks.InspectHook]
      "0.1.0"
      """
    end

    test "Bumping with pre hooks ignored", fixture do
      Application.put_all_env([
        {:versioce, [
            {:pre_hooks, [Versioce.PreHooks.InspectHook]},
            {:post_hooks, []},
          ]}
      ])

      assert capture_io(fn -> Mix.Task.rerun("bump", ["0.1.0", "--no-pre-hooks"]) end) == """
      Bumping version from #{fixture.current_version}:
      "0.1.0"
      Running post-hooks: []
      """
    end
    test "Bumping with post hooks ignored", fixture do
      Application.put_all_env([
        {:versioce, [
            {:pre_hooks, []},
            {:post_hooks, [Versioce.PostHooks.InspectHook]},
          ]}
      ])

      assert capture_io(fn -> Mix.Task.rerun("bump", ["0.1.0", "--no-post-hooks"]) end) == """
      Running pre-hooks: []
      Bumping version from #{fixture.current_version}:
      "0.1.0"
      """
    end
  end
end
