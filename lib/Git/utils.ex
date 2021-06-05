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
end

defmodule Versioce.Git.Hook do
  @moduledoc false

  @doc false
  defmacro __using__(_opts) do
    quote do
      @doc false
      def run(false, _) do
        {:error, "Optional dependency `git_cli` is not loaded."}
      end

      @doc false
      def run(params) do
        Code.ensure_loaded?(Git)
        |> run(params)
      end
    end
  end
end
