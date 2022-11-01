if Versioce.Utils.deps_loaded?([Git]) do
  defmodule Versioce.Changelog.DataGrabber.Git do
    @moduledoc """
    Datagrabber for changelog generation, `Versioce.Config.Changelog.datagrabber/0`

    Uses repository history to obtain and format data.
    """
    @behaviour Versioce.Changelog.DataGrabber

    alias Versioce.Changelog.DataGrabber.Version
    alias Versioce.Config
    alias Versioce.Git, as: VGit

    @type commit_group() :: %{
            version: String.t(),
            messages: [String.t()]
          }

    @impl Versioce.Changelog.DataGrabber
    def get_versions(new_version \\ "HEAD") do
      {
        :ok,
        new_version
        |> get_new_version_name()
        |> get_commit_groups()
        |> prepare_group_sections(Config.Changelog.anchors())
      }
    end

    @impl Versioce.Changelog.DataGrabber
    def get_version(version \\ "HEAD") do
      {
        :ok,
        version
        |> get_new_version_name()
        |> get_tag_commit_group()
        |> Version.make_version(Config.Changelog.anchors())
      }
    end

    defp get_new_version_name("HEAD"), do: "HEAD"
    defp get_new_version_name(name), do: name |> VGit.get_tag_name()

    defp prepare_group_sections(groups, anchors) do
      make_groups(groups, anchors, [])
    end

    defp make_groups([], _anchors, acc), do: acc

    defp make_groups([group | tail], anchors, acc) do
      make_groups(
        tail,
        anchors,
        [
          Version.make_version(group, anchors)
        ] ++ acc
      )
    end

    @spec get_commit_groups(String.t()) :: [commit_group()]
    defp get_commit_groups(version) do
      tags = VGit.get_tags()

      tags
      |> transform_to_ranges()
      |> Enum.map(&get_messages_from_range(&1))
      |> Kernel.++([
        get_unreleased_hash(tags)
        |> get_unreleased_messages(version, include_from: Enum.empty?(tags))
      ])
    end

    @spec get_tag_commit_group(String.t()) :: commit_group()
    defp get_tag_commit_group("HEAD" = version) do
      tags = VGit.get_tags()

      get_unreleased_hash(tags)
      |> get_unreleased_messages(version, include_from: Enum.empty?(tags))
    end

    defp get_tag_commit_group(version) do
      tags = VGit.get_tags()

      case Enum.find_index(tags, fn %{tag: x} -> x === version end) do
        0 = index ->
          get_messages_from_range(
            {[
               %{hash: VGit.initial_commit()},
               Enum.at(tags, index)
             ], index}
          )

        index ->
          get_messages_from_range(
            {[
               Enum.at(tags, index - 1),
               Enum.at(tags, index)
             ], index}
          )
      end
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

    defp get_unreleased_hash([]) do
      VGit.initial_commit()
    end

    defp get_unreleased_hash(tags) do
      tags
      |> Enum.at(-1)
      |> Map.get(:hash)
    end

    defp get_unreleased_messages(from, new_version, include_from: false) do
      messages =
        VGit.get_commit_messages_in_range(from, "@")
        |> Enum.map(fn %{message: message} -> message end)

      %{
        version: new_version,
        messages: messages
      }
    end

    defp get_unreleased_messages(from, new_version, include_from: true) do
      messages =
        VGit.get_commit_messages_in_range(from, "@")
        |> Enum.map(fn %{message: message} -> message end)

      %{
        version: new_version,
        messages: [VGit.get_message_from_hash(from) | messages]
      }
    end
  end
end
