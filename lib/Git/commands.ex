defmodule Versioce.Git do
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
  @spec add([String.t()]) :: String.t()
  def add(args \\ ["."]) do
    repo()
    |> Git.add!(args)
  end

  @doc """
  Make a commit with a message.
  """
  @spec commit(String.t()) :: String.t()
  def commit(message) do
    repo()
    |> Git.commit!(["-m", message])
  end

  @doc """
  Create a tag.
  """
  @spec tag(String.t(), String.t()) :: String.t()
  def tag(name, message) do
    repo()
    |> Git.tag!(["-a", name, "-m", message])
  end

  @doc """
  Returns a list of tags in `%{hash: "Commmit hash", tag: "Tag name"}` format
  """
  @spec get_tags() :: [%{hash: String.t(), tag: String.t()}]
  def get_tags() do
    repo()
    |> Git.tag!(["--sort=creatordate", "--format='%(refname:strip=2)|%(objectname)'"])
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
  @spec initial_commit() :: String.t()
  def initial_commit() do
    repo()
    |> Git.rev_list!(["--max-parents=0", "HEAD"])
    |> String.trim_trailing()
  end

  @doc """
  Get message of a commit by its hash.
  """
  @spec get_message_from_hash(String.t()) :: String.t()
  def get_message_from_hash(hash) do
    repo()
    |> Git.log!(["--pretty=format:'%B'", "-1", hash])
    |> String.replace("'", "")
    |> String.trim()
  end

  @doc """
  Get a list of messages from hash1 to hash2 in `%{hash: "Commmit hash", message: "Commit message"}` format
  """
  @spec get_commit_messages_in_range(String.t(), String.t()) :: [
          %{hash: String.t(), message: String.t()}
        ]
  def get_commit_messages_in_range(hash1, hash2) do
    repo()
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
end
