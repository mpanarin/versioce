defmodule Versioce.PostHooks.Git.Commit do
  @moduledoc """
  Runs a `git commit` in your repository.

  You can customize your commit message with `Versioce.Config.commit_message_template`
  """
  use Versioce.PostHook

  def run(version) do
    Versioce.Config.commit_message_template()
    |> String.replace("{version}", version, global: true)
    |> Versioce.Git.commit()

    version
  end
end

defmodule Versioce.PostHooks.Git.Add do
  @moduledoc """
  Runs a `git add` in your repository.

  By default only adds files from
  your `Versioce.Config.files`. To change that set `Versioce.Config.dirty_add`
  to `true`
  """
  use Versioce.PostHook

  def run(version) do
    if Versioce.Config.dirty_add() do
      Versioce.Git.add()
    else
      ["mix.exs" | Versioce.Config.files()]
      |> Versioce.Git.add()
    end

    version
  end
end

defmodule Versioce.PostHooks.Git.Tag do
  @moduledoc """
  Runs `git add -a -m` in your repository.

  You can change the tag  template as well as tag message template with
  `Versioce.Config.tag_template` and `Versioce.Config.tag_message_template`
  """
  use Versioce.PostHook

  def run(version) do
    message =
      Versioce.Config.tag_message_template()
      |> String.replace("{version}", version, global: true)

    Versioce.Config.tag_template()
    |> String.replace("{version}", version, global: true)
    |> Versioce.Git.tag(message)

    version
  end
end

defmodule Versioce.PostHooks.Git.Release do
  @moduledoc """
  An alias for: `Versioce.PostHooks.Git.Add`, `Versioce.PostHooks.Git.Commit`, `Versioce.PostHooks.Git.Tag`
  """
  use Versioce.PostHook
  alias Versioce.PostHooks.Git

  def run(version) do
    version
    |> Git.Add.run()
    |> Git.Commit.run()
    |> Git.Tag.run()
  end
end
