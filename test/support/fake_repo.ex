defmodule Versioce.Test.FakeRepository do
  @moduledoc """
  Fake repository for mocking git actions.
  """
  alias Git.Repository
  alias Versioce.Config.Git, as: GitConfig

  @repo_data [
    %{hash: "000", message: ":bulb: initial commit", tag: nil},
    %{hash: "111", message: ":sparkles: added new feature", tag: nil},
    %{hash: "222", message: ":white_check_mark: added tests", tag: "v0.0.1"},
    %{hash: "333", message: ":construction_worker: added CI", tag: nil},
    %{hash: "444", message: ":construction: this is WIP", tag: nil},
    %{hash: "555", message: ":art: improved formatting", tag: "v0.0.2"},
    %{hash: "666", message: ":children_crossing: improved accessibility", tag: nil},
    %{hash: "777", message: ":recycle: refactored some code", tag: nil},
    %{hash: "888", message: ":gun: deprecated a feature", tag: nil},
    %{hash: "999", message: ":fire: files removed", tag: "v0.1.0"},
    %{hash: "101010", message: ":coffin: dead code dropped", tag: nil},
    %{hash: "111111", message: ":bug: bug fixed", tag: nil},
    %{hash: "121212", message: ":rotating_light: security upgraded", tag: "v1.0.0"},
    %{hash: "131313", message: ":sparkles: unreleased change", tag: nil}
  ]

  def repo do
    %Repository{path: "."}
  end

  def add(_, _repo \\ repo()) do
    :ok
  end

  def commit(_, _repo \\ repo()) do
    :ok
  end

  def tag(_, _, _repo \\ repo()) do
    :ok
  end

  def get_tags(_repo \\ repo()) do
    @repo_data
    |> Enum.reject(fn commit -> commit.tag === nil end)
    |> Enum.map(fn %{hash: hash, tag: tag} -> %{hash: hash, tag: tag} end)
  end

  def initial_commit(_repo \\ repo()) do
    [initial | _] = @repo_data
    initial.hash
  end

  def get_message_from_hash(hash, _repo \\ repo()) do
    @repo_data
    |> Enum.find(fn %{hash: hash_} -> hash_ === hash end)
    |> Map.fetch!(:message)
  end

  def get_commit_messages_in_range(hash1, hash2, _repo \\ repo())

  def get_commit_messages_in_range(hash1, "HEAD", _repo),
    do: get_commit_messages_in_range(hash1, "@")

  def get_commit_messages_in_range(hash1, "@", _repo) do
    @repo_data
    |> Enum.reduce_while(nil, fn
      %{hash: hash}, nil ->
        if hash === hash1 do
          {:cont, []}
        else
          {:cont, nil}
        end

      map, acc ->
        {:cont, acc ++ [map]}
    end)
  end

  def get_commit_messages_in_range(hash1, hash2, _repo) do
    @repo_data
    |> Enum.reduce_while(nil, fn
      %{hash: hash}, nil ->
        if hash === hash1 do
          {:cont, []}
        else
          {:cont, nil}
        end

      %{hash: hash} = map, acc ->
        if hash === hash2 do
          {:halt, acc ++ [map]}
        else
          {:cont, acc ++ [map]}
        end
    end)
  end

  def get_tag_name(version_name) do
    GitConfig.tag_template()
    |> String.replace("{version}", version_name, global: true)
  end
end
