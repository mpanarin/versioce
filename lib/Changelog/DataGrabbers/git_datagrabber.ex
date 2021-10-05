defmodule Versioce.Changelog.DataGrabber.Git do
  @moduledoc """
  Datagrabber for changelog generation, `Versioce.Config.Changelog.datagrabber/0`

  Uses repository history to obtain and format data.
  """
  @behaviour Versioce.Changelog.DataGrabber

  alias Versioce.Changelog.Sections
  alias Versioce.Git, as: VGit
  alias Versioce.Config
  alias Versioce.Utils

  @impl Versioce.Changelog.DataGrabber
  def get_data(new_version \\ "HEAD") do
    with true <- Utils.deps_loaded?([Git]),
         [_tags] <- VGit.get_tags() do
      {
        :ok,
        new_version
        |> get_new_version_name()
        |> get_commit_groups()
        |> prepare_group_sections(Config.Changelog.anchors())
      }
    else
      [] ->
        {:error, "No project tags found, please tag your release"}

      false ->
        {:error,
         "Optional dependency `git_cli` is not loaded. It is required for Git Datagrabber"}
    end
  end

  defp get_new_version_name("HEAD"), do: "HEAD"
  defp get_new_version_name(name), do: name |> VGit.get_tag_name()

  defp prepare_group_sections(groups, anchors) do
    make_groups(groups, anchors, [])
  end

  defp make_groups([], _anchors, acc), do: acc

  defp make_groups([%{messages: messages} = group | tail], anchors, acc) do
    make_groups(
      tail,
      anchors,
      [
        %{
          version: group.version,
          sections: Sections.from_string_list(messages, anchors)
        }
      ] ++ acc
    )
  end

  defp get_commit_groups(new_version) do
    tags = VGit.get_tags()

    tags
    |> transform_to_ranges()
    |> Enum.map(&get_messages_from_range(&1))
    |> Kernel.++([
      tags
      |> Enum.at(-1)
      |> Map.get(:hash)
      |> get_unreleased_messages(new_version)
    ])
  end

  defp transform_to_ranges(commits) do
    [%{hash: VGit.initial_commit()} | commits]
    |> Stream.chunk_every(2, 1, :discard)
    |> Stream.with_index()
    |> Enum.to_list()
  end

  defp get_messages_from_range({[%{hash: from}, %{hash: to, tag: tag}], 0}) do
    messages =
      (VGit.get_commit_messages_in_range(from, to) ++
         [%{message: VGit.get_message_from_hash(from)}])
      |> Enum.map(fn %{message: message} -> message end)

    %{
      version: tag,
      messages: messages
    }
  end

  defp get_messages_from_range({[%{hash: from}, %{hash: to, tag: tag}], _}) do
    messages =
      VGit.get_commit_messages_in_range(from, to)
      |> Enum.map(fn %{message: message} -> message end)

    %{
      version: tag,
      messages: messages
    }
  end

  defp get_unreleased_messages(from, new_version) do
    messages =
      VGit.get_commit_messages_in_range(from, "@")
      |> Enum.map(fn %{message: message} -> message end)

    %{
      version: new_version,
      messages: messages
    }
  end
end
