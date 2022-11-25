if Versioce.Utils.deps_loaded?([Git]) do
  alias Versioce.Config.Git, as: GitConfig

  defmodule Versioce.Git do
    # coveralls-ignore-start
    @moduledoc """
    Git utility functions for `versioce` module.
    """

    @doc """
    Get git repository.
    """
    @spec repo() :: Git.Repository.t()
    def repo do
      Git.init!()
    end

    @doc """
    Stage files.
    """
    @spec add([String.t()], Git.Repository.t()) :: String.t()
    def add(args \\ ["."], repo \\ repo()) do
      repo
      |> Git.add!(args)
    end

    @doc """
    Make a commit with a message.
    """
    @spec commit(String.t(), Git.Repository.t()) :: String.t()
    def commit(message, repo \\ repo()) do
      repo
      |> Git.commit!(["-m", message])
    end

    @doc """
    Create a tag.
    """
    @spec tag(String.t(), String.t(), list(String.t()), Git.Repository.t()) :: String.t()
    def tag(name, message, params \\ [], repo \\ repo()) do
      params = ["-a", name, "-m", message | params]

      repo
      |> Git.tag!(params)
    end

    @doc """
    Returns a list of tags in `%{hash: "Commmit hash", tag: "Tag name"}` format
    """
    @spec get_tags(Git.Repository.t()) :: [%{hash: String.t(), tag: String.t()}]
    def get_tags(repo \\ repo()) do
      repo
      |> Git.tag!([
        "--list",
        "--sort=creatordate",
        "--format='%(refname:strip=2)|%(objectname)'",
        "--merged",
        "@"
      ])
      |> String.replace("'", "")
      |> String.split("\n", trim: true)
      |> Enum.map(fn str ->
        [tag, hash] = String.split(str, "|", trim: true)

        %{
          tag: tag,
          hash: hash
        }
      end)
    end

    @doc """
    Get initial commit hash.
    """
    @spec initial_commit(Git.Repository.t()) :: String.t()
    def initial_commit(repo \\ repo()) do
      repo
      |> Git.rev_list!(["--max-parents=0", "HEAD"])
      |> String.trim_trailing()
    end

    @doc """
    Get message of a commit by its hash.
    """
    @spec get_message_from_hash(String.t(), Git.Repository.t()) :: String.t()
    def get_message_from_hash(hash, repo \\ repo()) do
      repo
      |> Git.log!(["--pretty=format:'%B'", "-1", hash])
      |> String.replace("'", "")
      |> String.trim()
    end

    @doc """
    Get a list of messages from hash1 to hash2 in `%{hash: "Commmit hash", message: "Commit message"}` format
    """
    @spec get_commit_messages_in_range(String.t(), String.t(), Git.Repository.t()) :: [
            %{hash: String.t(), message: String.t()}
          ]
    def get_commit_messages_in_range(hash1, hash2, repo \\ repo()) do
      repo
      |> Git.log!(["--pretty=format:'%H|%B%|%'", "#{hash1}..#{hash2}"])
      |> String.replace("'", "")
      |> String.split("%|%", trim: true)
      |> Enum.map(fn str ->
        [hash, message] = String.split(str, "|", trim: true)

        %{
          hash: hash |> String.trim(),
          message: message |> String.trim_trailing()
        }
      end)
    end

    @doc """
    Generate tag name according to `Versioce.Config.Git.tag_template/0`.
    """
    @spec get_tag_name(String.t()) :: String.t()
    def get_tag_name(version_name) do
      GitConfig.tag_template()
      |> String.replace("{version}", version_name, global: true)
    end
  end

  # coveralls-ignore-stop
end
