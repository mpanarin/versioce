if Versioce.Utils.deps_loaded?([Git]) do
  defmodule Versioce.PostHooks.Git.Commit do
    @moduledoc """
    Runs a `git commit` in your repository.

    You can customize your commit message with `Versioce.Config.Git.commit_message_template/0`
    """
    use Versioce.PostHook

    def run(version) do
      Versioce.Config.Git.commit_message_template()
      |> String.replace("{version}", version, global: true)
      |> Versioce.Git.commit()

      {:ok, version}
    end
  end

  defmodule Versioce.PostHooks.Git.Add do
    @moduledoc """
    Runs a `git add` in your repository.

    By default only adds files from
    your `Versioce.Config.files/0`. To change that set `Versioce.Config.Git.dirty_add/0`
    to `true`
    """
    use Versioce.PostHook

    def run(version) do
      if Versioce.Config.Git.dirty_add() do
        Versioce.Git.add()
      else
        ["mix.exs" | Versioce.Config.files() ++ Versioce.Config.Git.additional_files()]
        |> Versioce.Git.add()
      end

      {:ok, version}
    end
  end

  defmodule Versioce.PostHooks.Git.Tag do
    @moduledoc """
    Runs `git add -a -m` in your repository.

    You can change the tag template as well as tag message template with
    `Versioce.Config.Git.tag_template/0` and `Versioce.Config.Git.tag_message_template/0`
    """
    use Versioce.PostHook

    def run(version) do
      message =
        Versioce.Config.Git.tag_message_template()
        |> String.replace("{version}", version, global: true)

      version
      |> Versioce.Git.get_tag_name()
      |> Versioce.Git.tag(message)

      {:ok, version}
    end
  end

  defmodule Versioce.PostHooks.Git.Release do
    @moduledoc """
    An alias for: `Versioce.PostHooks.Git.Add`, `Versioce.PostHooks.Git.Commit`, `Versioce.PostHooks.Git.Tag`
    """
    use Versioce.PostHook

    alias Versioce.PostHooks.Git

    def run(version) do
      with {:ok, version} <- Git.Add.run(version),
           {:ok, version} <- Git.Commit.run(version),
           {:ok, version} <- Git.Tag.run(version) do
        {:ok, version}
      else
        error -> {:error, "Error occured: #{inspect(error)}"}
      end
    end
  end
end
