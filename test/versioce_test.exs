defmodule VersioceTest do
  use ExUnit.Case, async: false
  import ExUnit.CaptureIO
  alias Mix.Tasks.Bump
  use Mimic

  setup do
    %{
      current_version: Mix.Project.config()[:version]
    }
  end

  test "Current version task", fixture do
    assert capture_io(fn -> Mix.Task.rerun("bump.version") end) == fixture.current_version <> "\n"
  end

  describe "Version bumping task" do
    setup do
      Versioce.Bumper.Files
      |> stub(:update_version_files, fn _, _ -> :ok end)

      :ok
    end

    test "No bumping if we couldn't get current_version" do
      Application.put_all_env([
        {:versioce,
         [
           {:pre_hooks, [Versioce.PreHooks.Inspect]},
           {:post_hooks, []}
         ]}
      ])

      assert capture_io(fn ->
               Bump.run(["0.1.1"], {:error, "no current version"})
             end) == """
             Error: no current version
             """
    end

    test "No hooks, only bump", fixture do
      Application.put_all_env([
        {:versioce,
         [
           {:pre_hooks, []},
           {:post_hooks, []}
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
        {:versioce,
         [
           {:pre_hooks, [Versioce.PreHooks.Inspect]},
           {:post_hooks, []}
         ]}
      ])

      assert capture_io(fn -> Mix.Task.rerun("bump", ["0.1.0"]) end) == """
             Running pre-hooks: [Versioce.PreHooks.Inspect]
             ["0.1.0"]
             Bumping version from #{fixture.current_version}:
             "0.1.0"
             Running post-hooks: []
             """
    end

    test "Bumping with post hooks", fixture do
      Application.put_all_env([
        {:versioce,
         [
           {:pre_hooks, []},
           {:post_hooks, [Versioce.PostHooks.Inspect]}
         ]}
      ])

      assert capture_io(fn -> Mix.Task.rerun("bump", ["0.1.0"]) end) == """
             Running pre-hooks: []
             Bumping version from #{fixture.current_version}:
             "0.1.0"
             Running post-hooks: [Versioce.PostHooks.Inspect]
             "0.1.0"
             """
    end

    test "Bumping with pre hooks ignored", fixture do
      Application.put_all_env([
        {:versioce,
         [
           {:pre_hooks, [Versioce.PreHooks.Inspect]},
           {:post_hooks, []}
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
        {:versioce,
         [
           {:pre_hooks, []},
           {:post_hooks, [Versioce.PostHooks.Inspect]}
         ]}
      ])

      assert capture_io(fn -> Mix.Task.rerun("bump", ["0.1.0", "--no-post-hooks"]) end) == """
             Running pre-hooks: []
             Bumping version from #{fixture.current_version}:
             "0.1.0"
             """
    end

    test "Bumping with errors in pre hooks" do
      Application.put_all_env([
        {:versioce,
         [
           {:pre_hooks, [Versioce.TestHelper.FailingHook]},
           {:post_hooks, []}
         ]}
      ])

      assert capture_io(fn -> Mix.Task.rerun("bump", ["0.1.0"]) end) == """
             Running pre-hooks: [Versioce.TestHelper.FailingHook]
             Hook failed
             """
    end

    test "Bumping with errors in post hooks", fixture do
      Application.put_all_env([
        {:versioce,
         [
           {:pre_hooks, []},
           {:post_hooks, [Versioce.TestHelper.FailingHook]}
         ]}
      ])

      assert capture_io(fn -> Mix.Task.rerun("bump", ["0.1.0"]) end) == """
             Running pre-hooks: []
             Bumping version from #{fixture.current_version}:
             "0.1.0"
             Running post-hooks: [Versioce.TestHelper.FailingHook]
             Hook failed
             """
    end

    test "Pre hooks pipeline stops on error" do
      Application.put_all_env([
        {:versioce,
         [
           {:pre_hooks, [Versioce.TestHelper.FailingHook, Versioce.PreHooks.Inspect]},
           {:post_hooks, []}
         ]}
      ])

      assert capture_io(fn -> Mix.Task.rerun("bump", ["0.1.0"]) end) == """
             Running pre-hooks: [Versioce.TestHelper.FailingHook, Versioce.PreHooks.Inspect]
             Hook failed
             """
    end

    test "Post hooks pipeline stops on error", fixture do
      Application.put_all_env([
        {:versioce,
         [
           {:pre_hooks, []},
           {:post_hooks, [Versioce.TestHelper.FailingHook, Versioce.PostHooks.Inspect]}
         ]}
      ])

      assert capture_io(fn -> Mix.Task.rerun("bump", ["0.1.0"]) end) == """
             Running pre-hooks: []
             Bumping version from #{fixture.current_version}:
             "0.1.0"
             Running post-hooks: [Versioce.TestHelper.FailingHook, Versioce.PostHooks.Inspect]
             Hook failed
             """
    end
  end
end
